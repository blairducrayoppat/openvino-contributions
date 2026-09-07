# openvino.genai PR #4392 — VLM continuous batching, `echo=True`, row-level results

Row-level data behind the comment on
[openvinotoolkit/openvino.genai#4392](https://github.com/openvinotoolkit/openvino.genai/pull/4392#issuecomment-5576244697).
Measured on Windows 11 on an Intel Core Ultra 7 258V with an Arc 140V iGPU, 2026-09-07.

## What was measured

Whether the prompt token ids a VLM `ContinuousBatchingPipeline` hands the sampler reach the returned
output, on the PR branch and on the commit it branched from, with `GenerationConfig.echo` as the
input swept.

Two refs, built from source in separate worktrees:

| | ref |
|---|---|
| PR head | `e6fced66b1b8ccc685fe9ce8c10f199f5c095418` |
| merge base | `c9fff70b9f960bdb0c484fe0c2c1bed9d697bbaf` |

Master was `26144e25d8ac8945f55be6319728498e04e33530` at the time, four commits ahead of the merge
base, with no file under `src/` in the compare. **Nothing here was run at master.**

## Build identity

Both refs, identically: Ninja, `Release`, MSVC `19.44.35222.0`, `-DENABLE_PYTHON=ON
-DENABLE_TESTS=ON`, against the OpenVINO nightly wheel `2026.5.0.dev20260903`, with
`thirdparty/openvino_tokenizers` at `824033c3061d73d50784872248cdb55aa04674aa` in both trees.
Confirmed equal by comparing the generated CMake cache and compiler-identification files in the two
build trees — neither build tree is published here — so the compiled commit is the only difference
between the two sides of every comparison.

Environment: Windows 11 build 26200, Python 3.11.9, Arc 140V driver `32.0.101.8991`,
the upstream `tests/python_tests/requirements.txt` as pinned at the merge base — transformers `5.0.0`,
optimum-intel `2.2.0.dev0+4f1a926`. Master has since moved that pin to transformers `5.5.4` /
optimum-intel `dd4ed1a`; that combination was **not** run.

## Files

| file | contents |
|---|---|
| `all_runs.csv` | 204 rows, one per unit, on a union schema. 60 pytest matrix + 108 `echo` sweep + 36 text-only bounding sweep. |
| `COLUMNS.md` | Every column, what it means, and whether the value was read back, passed in, or asserted. |
| `source_pytest_matrix.csv` | The pytest matrix as recorded, redacted. |
| `source_echo_sweep.csv` | The `echo` sweep as recorded, redacted. |
| `source_textonly_sweep.csv` | The text-only bounding sweep as recorded, redacted. |
| `reproducer_one_path.py` | The reproducer. Makes exactly one of the three calls in its own process, so a crash is attributed by which process died. Takes `--models-path`, `--device`, `--path`, `--echo`. |
| `test_variants.diff` | Every change made to the upstream test file, in full: six lines across two hunks. |
| `build_public_table.py` | Builds the joined table from the three sources. It writes the staged copy at full fidelity; redaction and screening are separate steps. |

Per-unit log files are not published. `run_artifact_id` is the filename of the log a row came
from — an identifier, not a path to something in this package.

Before publication the staged copy was rewritten by the workspace's shared redaction step and then
gated by its content screen, which exits non-zero on a private project or platform name, internal
tooling paths, agent role names, host identity, credential-shaped strings, personal email
addresses, absolute local paths and UNC paths, and which refuses to run at all if its own
known-bad samples stop being caught. On this package: 894 path occurrences rewritten across 4
files, then the screen passed with no finding in 7 files.

## Reproducibility

Everything was run twice, as two complete passes. The passes agree on **108/108** exit codes in the
`echo` sweep, and on **54/54** of the matrix units that produce a comparable artifact (42 pytest +
9 probe + 3 gtest). The other 6 matrix units are the crashing runs, which write no artifact by
design; those were the same 6 keys in both passes. The second pass is what is published here.

N=3 per configuration throughout.

## What this data does not establish

Stated in the upstream comment and repeated here, because a table invites more weight than the
design carries:

1. **No control whose true answer is provably zero on the crashing configuration.** The repeated
   same-build arm never reaches the crash path, so no resolution limit sits under the split.
2. **The `string` call path is not an inert control.** It delegates through `pipeline_base.cpp:69`
   into the VLM string overload at `:313`, which this PR edits. It answers identically on both
   builds, which is what makes the table readable — it is not evidence of an untouched path.
3. **Measured at the merge base, not at master**, and at the transformers `5.0.0` pin, not `5.5.4`.
4. **One OpenVINO build and one toolchain.** No second compiler, no second nightly.
5. **Two tiny random VLMs and one text-only LLM.** No full-size VLM, and no image-bearing prompt —
   the test under examination is text-only.
6. **No GPU row for `tiny-random-qwen2vl`.** That model's `head_size` is 8 and the GPU
   PagedAttention kernel requires at least 16, so the configuration cannot be built. The gap belongs
   to the model, not to the PR.
7. **The fault is not localised to a line.** There is an exit code and a reproducer, not a stack; no
   debugger was available on this machine.

One further caveat, from running the neighbouring continuous-batching tests: they fail on **both**
builds, 3/3 each, with `Eltwise shape infer input shapes dim index: 1 mismatch` — the CVS-186059
condition the project's own test file records for gemma3. Identical on both sides, so it does not
bear on the comparison, but the environment is partly broken independently of this PR.

## Licence and provenance

Data produced by an independent contributor on personal hardware. Not an Intel product, not an
official benchmark, and not a claim about any configuration other than the ones in the table.
