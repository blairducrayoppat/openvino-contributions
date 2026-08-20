# npu_compiler #266 / #265 / #34651 — dev-build reproduction & root-cause findings

Date: 2026-06-11 (overnight autonomous session)
Machine: Intel Core Ultra 7 258V (Lunar Lake), NPU 4 (NPU40XX), Windows 11
OpenVINO @ `e4e180d` (2026.2.0) · npu_compiler develop @ `30d2bb87b` · LLVM 21.1.8, RelWithDebInfo + assertions
GitHub identity: blairducrayoppat. NOTHING posted to GitHub — all local pending LA review.

## 1. Toolchain built (from source, on this box)

- OpenVINO @ the commit npu_compiler pins (`validation/openvino_config.json`), NPU plugin + `compile_tool`,
  `ENABLE_DEBUG_CAPS=ON`. Python bindings OFF (system Python 3.14 too new; not needed).
- npu_compiler `developer-build-relwithdebinfo` (`ENABLE_DEVELOPER_BUILD=ON`). One fix:
  `-DLLVM_ENABLE_DIA_SDK=OFF` (LLVM auto-enabled PDB/DIA support needing ATL headers absent from VS Build Tools).
- Tools: `vpux-opt`, `vpux-translate`, `compile_tool`, `FileCheck`, `npuUnitTests`, plus the in-plugin compiler
  `openvino_intel_npu_compiler.dll`. Optimized **with assertions** → named asserts instead of silent `0xC0000005`.
- Confirmed `compile_tool`/harness with `NPU_COMPILER_TYPE=PLUGIN` loads compiler ID
  `2026.2.0-67-30d2bb87b30-develop` = our build. Every result below comes from our compiler.

## 2. #34617 / PR #34651 — reproduced from the CLI, no GenAI (clean win)

`compile_tool -m openvino-int4-npu\openvino_model.xml -d NPU -c config.txt -shape "input_ids[1,128],...,beam_idx[1]"`
(config: `NPU_COMPILER_TYPE PLUGIN`, `NPU_PLATFORM 4000`) → deterministic, identical to #34617:

```
Exception from src\core\src\partial_shape.cpp:266: to_shape was called on a dynamic shape.
```

Dies in the **frontend** ("Common nGraph passes"), before the MLIR pipeline — because `-shape` pins the 4 inputs but
the stateful KV-cache dim stays dynamic. This is a **GenAI-free, maintainer-runnable** repro of the bug PR #34651
guards (previously needed the full LLMPipeline). Directly strengthens #34651 — the maintainer-invited PR (YuChern-Intel:
"since you have the implementation ready, you are free to submit the PR").

## 3. #266 / #265 — the zero-dim crash does NOT reproduce on develop; it has SHIFTED

To reach the MLIR pipeline (where #266 lives) the model must be fully static incl. the KV-cache dim. `compile_tool`'s
own dynamism pre-check blocks that, so a ~30-line C++ harness (`harness/repro266.cpp`) calls `ov::Core::compile_model`
directly with NPUW's static-LLM properties — exactly what GenAI does under the hood:
`NPU_USE_NPUW=YES, NPUW_LLM=YES, NPUW_LLM_MAX_PROMPT_LEN=1024, NPUW_LLM_MIN_RESPONSE_LEN=128`.

Result: the compile now runs **167 MLIR passes** on the `kv1152` generate sub-model, then fails — but NOT with the
zero-dim `as_convolution` LLVM ABORT of #34450/#266. Instead:

```
StopLocationVerifierPass Pass failed : Found 40 duplicated names after full verification
Failed to compile Model1106_kv1152_FCEW000__0 for all devices in [NPU]   (npuw/compiled_model.cpp:551)
```

- **No literal zero-dim (`tensor<0x...>`) appears anywhere in the 167-pass IR tree.** The #266 guard target does not
  reproduce on current develop — strong evidence it was changed/addressed upstream between 2026.0 and develop.
- A **local crash reproducer** (`reproducer_clean.mlir`, scoped to `setup-location-verifier`) + the full per-pass IR
  tree (`tree/`) are captured.

## 4. Root cause (the "fix at the source" andrey-golubev asked for)

The 40 duplicated names are dominated by the four attention-projection MatMuls. In the post-split IR
(`32_132_split-conv-with-multiple-fq.mlir`) the SAME location is attached to thousands of ops:

| location name | # ops sharing it |
|---|---|
| `...layers.0.self_attn.q_proj/ov_ext::linear/MatMul` | 10,285 |
| `...self_attn.o_proj/.../MatMul` | 5,235 |
| `...self_attn.v_proj/.../MatMul` | 5,184 |
| `...self_attn.k_proj/.../MatMul` | 5,165 |
| `...o_proj.weight/fq_weights_1` | 50 |

i.e. the **grouped-INT4 decomposition of the attention MatMuls explodes a single MatMul into thousands of sub-ops, all
inheriting the original op's location name**, which the full-mode location verifier then rejects. This is almost
certainly the SAME root as the original zero-dim crash — the pathological grouped-INT4 attention-MatMul handling on
NPU — surfacing as a different symptom on newer compiler code. Note dmfallak already linked StopLocationVerifierPass
failures to the #34450 class on #35641 ("structurally the same as #34450").

So the real source fix is upstream in the grouped-INT4 MatMul decomposition (GroupWisePatternRewriter / the FC
unroll + conv-split chain), not the downstream zero-dim guards of #265/#266.

## 5. What this means for the three PRs (for LA decision — NOT yet acted on)

- **#34651** (to_shape dynamic guard): strongest. Maintainer-invited, and now has a clean CLI repro. → nudge + attach repro.
- **#265 / #266** (zero-dim guards): the guarded crash no longer reproduces on develop. Risk: "guards a bug that's
  gone." Two honest options to put to the maintainer: (a) keep as defense-in-depth (andrey-golubev already accepted
  that framing) and say so, or (b) **pivot the contribution to the now-reproducing failure** — the duplicated-names
  verifier rejection — which has a clean local reproducer and a clear root (attention-MatMul grouped-INT4 explosion).
  Option (b) is the higher-value, currently-demonstrable contribution.
- The big prize andrey-golubev pointed at — fix at the source — is the grouped-INT4 attention-MatMul decomposition.
  Substantial, but now characterized with a reproducer and a concrete first suspect (the q_proj MatMul → 10k-op blowup).

## 6. Reproduce again
- `harness\repro266.exe <model.xml>` with `bin\intel64\RelWithDebInfo` on PATH → the duplicated-names failure (27s).
- Add the `IE_NPU_IR_*` env vars in `run_harness_tree.cmd` for the 167-pass IR tree.
- Artifacts: `reproducer_clean.mlir`, `tree/`, `*_console.log`, this file. ~Disk: 102 GB free after builds.
