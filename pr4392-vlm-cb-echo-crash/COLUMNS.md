# `all_runs.csv` — column reference

204 rows, one per executed unit, joined from three sweeps that share a subject but not a schema.
`sweep` says which one a row came from, and every column that cannot apply to that sweep carries an
explicit token (`n/a:<sweep>`, `n/a:no_pytest`, `n/a:whole_test`, `n/a:selected_by_fixture`,
`unmeasured:psutil`) rather than a blank. **A blank cell and a redacted cell mean different things;
there are no blank cells.** The three redacted source CSVs sit alongside so the join can be checked
against its inputs.

Compare only rows sharing `build_sha`, `ov_version`, `gpu_driver` and `tokenizers_submodule`. Any
other comparison is cross-build and has to say so.

## Provenance of each value

Three kinds, and the distinction matters more than the values:

- **read back** — obtained from the running system at the moment of the run, not assumed.
- **passed in** — the value the harness supplied to the child, recorded as supplied.
- **asserted** — stated from knowledge of the machine and not present in any artifact. Only one
  column is of this kind, and it is named below.

| column | provenance | meaning |
|---|---|---|
| `sweep` | passed in | `pytest_matrix` (the project's own test under pytest), `echo_sweep` (one call per process, `echo` swept), `textonly_sweep` (same, on a text-only LLM, to bound the finding). |
| `arm` | passed in | Configuration label. In the sweeps it encodes build, model, device, call path and echo level. |
| `rep` | passed in | 1-based repetition. N=3 per configuration throughout. |
| `utc_start` | read back | UTC start of the unit, ISO basic. |
| `wall_s` | read back | Wall-clock seconds for the unit, from a monotonic clock. Includes process start and model load. |
| `build_label` | passed in | `base` = the PR's merge base `c9fff70b`; `prhead` = PR head `e6fced66`. |
| `build_sha` | read back | `git rev-parse HEAD` of the worktree the unit ran against. |
| `build_dir` | redacted path | Which of the two build trees was on `PYTHONPATH`: `build/merge_base/` or `build/pr_head/`. |
| `device` | passed in | Device string given to `ContinuousBatchingPipeline`. Never blank: where the fixture's own hardcoded literal applied, that literal is recorded. |
| `model` | passed in | Model id or local export name. |
| `models_path` | redacted path | Converted-model directory, as `model_cache/<id>`. `n/a:selected_by_fixture` where the project's own fixture chose it. |
| `call_path` | passed in | Which call the unit made: `string` (`generate(list[str])`), `chat_history` (`generate(list[ChatHistory])`), `add_request`. `n/a:whole_test` for pytest rows, which make all three. |
| `echo` | passed in | `GenerationConfig.echo` for the unit. `true:set_inside_the_test` for pytest rows, where the project's own test sets it. |
| `test_variant` | passed in | Which variant of the upstream `tests/python_tests/test_vlm_pipeline.py` was installed. `V0_shipped.py` is byte-identical to the file PR #4392 ships; `V1_envparam.py` changes one fixture expression so it reads two environment variables, both defaulting to the shipped literals; `V2_envparam_textsfix.py` is V1 plus two `.texts` → `m_generation_ids` corrections. Both changes are reproduced in full in `test_variants.diff` in this package — together they are six lines. |
| `test_file_sha256` | read back | sha256 of the installed test file, so the variant claim is checkable rather than asserted. Identical between paired base/head arms in every comparison. |
| `tests` | passed in | pytest node ids for matrix rows; `one_path.py` for sweep rows, which is published here as `reproducer_one_path.py` — it makes exactly one of the three calls in its own process, so a crash is attributed by which process died. |
| `outcome` | derived | `PASS`, `FAIL`, `XFAIL_OR_SKIP`, `MIXED`, `CRASH_ACCESS_VIOLATION`, `TIMEOUT_KILLED`, `HARNESS_ERROR` (pytest); `COMPLETED`, `CRASH`, `COMPLETED_NO_MARKER`, `NONZERO_EXIT` (sweeps). Derived from `exit_code` and the child's own success marker together — a zero exit without the marker is never counted as a pass. |
| `exit_code` | read back | Child process exit code. `3221225477` is `0xC0000005`, an access violation. |
| `crash_kind` | derived | `access_violation_0xC0000005` or `none`. |
| `last_step` | read back | The last `STEP` line the child printed before exiting — how a crash is attributed when there is no traceback. |
| `n_tests` / `n_passed` / `n_failed` / `n_skipped` | read back | Parsed from the junit XML, not from stdout text. `n_skipped` covers xfail-at-setup. A crashed pytest writes no junit, so these read `0` and `outcome` carries the crash. |
| `case_outcomes` | read back | `testname=outcome` per collected case. |
| `failure_detail` | read back | First failure message, truncated. Quoted output is preserved byte-for-byte, including the original backslash paths inside OpenVINO's own error strings — only the harness's own local paths were redacted. |
| `string_prompt_present` / `chat_history_prompt_present` / `add_request_prompt_present` | read back | Whether the prompt string appears in each path's echoed output. `exc:<Type>` if that path raised. |
| `string_result_type` / `chat_history_result_type` | read back | The Python type each `generate` overload actually returned. |
| `add_request_generated_id_count` | read back | Token ids returned by `handle.read_all()[0]`. |
| `add_request_negative_ids` | read back | Whether any returned id is negative (the internal visual-row markers this PR filters). |
| `echo_text_sha256` / `result_text_sha256` | derived | sha256 of the decoded echo, so two rows can be compared without reproducing the text. |
| `result_line` | read back | The child's own `RESULT` line, truncated to 200 characters. |
| `prompt_token_count` | read back | Tokens in the prompt, from the pipeline's own tokenizer. |
| `load_s` | read back | Seconds to construct the pipeline. |
| `peak_rss_mb` | read back | Peak resident set of the child process tree, sampled at 2 Hz. `unmeasured:psutil` if sampling failed. |
| `build_type` / `generator` | passed in | `Release` / `Ninja` for every row. |
| `tokenizers_submodule` | read back | `thirdparty/openvino_tokenizers` commit; identical at both refs, so not a confound. |
| `ov_version` | read back | Installed `openvino` distribution version — the wheel both builds compiled against. |
| `transformers` / `optimum_intel` | read back | Installed versions. They select the fixture's model and drive the export. |
| `gpu_driver` | read back | Arc 140V driver version, read from `Win32_VideoController` at run start. |
| `run_artifact_id` | read back | The filename of the log, junit XML or probe JSON the row was parsed from — an **identifier, not a path**. Unique per run by construction (arm, rep and a UTC stamp), so it joins a row to its source record. Those files are not part of this package, and the column deliberately carries no directory so it cannot read as a citation you could open. |

The one **asserted** value in this dataset is not a column: the CPU model named in the README
(`Intel Core Ultra 7 258V`) appears in no artifact. The OS build and Python version were read back
into the probe JSON, and the GPU driver is read live into every row, but the CPU string is stated
from knowledge of the machine.

## Redaction applied before publication

`build_public_table.py` writes the staged copy at full fidelity. A separate redaction step then
rewrites local absolute paths in that staged copy only, so the private record keeps every path:

| was | is |
|---|---|
| the PR-head build tree | `build/pr_head/` |
| the merge-base build tree | `build/merge_base/` |
| the converted-model cache | `model_cache/<model id>` |
| anything else under the workspace | `workspace/` |

Nothing was blanked, and **no non-path text was altered** — in particular the backslash source
paths inside OpenVINO's own exception strings in `failure_detail` are byte-verbatim, so a cell
still matches the log it came from. 894 occurrences were rewritten across 4 files.

A content screen then gated the publish, and it is the gate rather than the redaction step: it
fails on a private project or platform name, internal tooling paths, agent role names, host
identity, credential-shaped strings, personal email addresses, absolute local paths and UNC
paths. It refuses to run at all if its own catalogue of known-bad samples — real values taken
from packages that were caught, including cells from this dataset before redaction — stops being
caught, and it carries must-not-flag samples so it cannot be tightened into flagging quoted
upstream output. It passed this package with no finding in 7 files.

## Controls in this set, and the control this set does not have

- The `string` call path ran on both builds at both `echo` levels. It is a **comparison arm, not an
  inert one**: on a VLM pipeline `generate(list[str])` delegates through `pipeline_base.cpp:69` into
  the VLM string overload at `:313`, which this PR edits. That it answers identically on both builds
  is what makes the rest of the table readable; it is not evidence that the PR left a path alone.
- `A_prhead_shipped_cpu_open` and `A_prhead_shipped_cpu_close` are the same configuration run first
  and last, bounding drift across the session.
- `K_prhead_v1_noenv_cpu` runs the parameterised test file with neither environment variable set. By
  construction its answer must equal the `V0_shipped.py` arms, and it does — so the instrument does
  not move the result.
- **There is no control whose true answer is provably zero on the crashing configuration.** The
  repeated arm above never reaches the crash path, and the `string` arm is not inert. The
  crash/no-crash split is a clean binary across 36 cells in every repetition, but no resolution
  limit is established underneath it.
