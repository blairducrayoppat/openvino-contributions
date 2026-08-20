### Details:

**Problem.** Models with an *unbounded* dynamic dimension (dynamic with no finite upper bound, i.e. upper bound `INT64_MAX`) — common in LLM exports via `optimum-cli` / optimum-intel — are passed by the NPU plugin straight through to the VPUX compiler, which then fails deep inside its shape analysis with an opaque, non-actionable error. On current `master` (2026.2) this surfaces on real hardware as:

```
[ERROR] Upper bounds are not specified for node 'Result_2': input '0' bounds are '[1, 9223372036854775807, 64]'
[NPU_VCL] Compiler returned msg: Missing upper bound for one or more nodes.
```
(earlier driver/compiler builds reported `to_shape was called on a dynamic shape` — same root cause: the `INT64_MAX` upper bound.)

The existing internal option `NPU_DYNAMIC_SHAPE_TO_STATIC` does not help here — it would apply `INT64_MAX` as a static dimension, which is meaningless.

**Fix.** A small validation `intel_npu::validate_no_unbounded_dynamic_dimensions(model)` (new `model_validation.{hpp,cpp}`) is called from `Plugin::compile_model()` after batch handling (which may resolve a dynamic batch axis) and before the compiler. It checks every parameter and output dimension for `dim.is_dynamic() && !dim.get_interval().has_upper_bound()` and throws an actionable `ov::Exception`:

```
NPU does not support models with unbounded dynamic dimensions. Parameter 'input_ids'
has dimension [1] with no finite upper bound (upper bound is INT64_MAX). Please reshape
the model to use static shapes before compiling for the NPU device:
    model.reshape({<static_shape>})
See: https://docs.openvino.ai/2026/openvino-workflow/model-preparation/setting-input-shapes.html
```

**Why a helper instead of an inline block.** Extracting the check into a device-free function makes it directly unit-testable *without* an NPU device, so the tests run on CPU-only precommit runners. (An inline guard is only reachable via `compile_model(model, "NPU")`, whose test `GTEST_SKIP()`s when no NPU is present — i.e. it would never assert in gating CI.) The function is compiled into the `ov_npu_unit_tests` target via `OBJECT_FILES`. The refactor also: de-duplicates the parameter/output message into a single definition, guards against dynamic rank before indexing dimensions, and reports the *producing node's* name for unbounded outputs (since `Result` nodes usually have no friendly name).

**Behavior / regression risk.** Zero for valid models — it only rejects models that already fail in the compiler. Static shapes, bounded dynamic shapes, and dynamic-rank models are unaffected. All APIs used are existing public OpenVINO C++ APIs.

**Verification.**
- `ov_npu_unit_tests` → `NPUUnboundedDynamicShape.*` (6 cases: unbounded input; unbounded output via `Range`; multi-input offending-name + dimension-index; bounded-dynamic allowed; fully static allowed; dynamic-rank allowed) — **6/6 pass**.
- Mutation check: weakening the predicate to `is_dynamic()`-only makes the bounded-dynamic case fail — confirms the tests are not tautological.
- **End-to-end on real NPU** (Intel Core Ultra 7 258V, NPU 4000): `compile_model(<unbounded model>, "NPU")` — *before:* opaque `Missing upper bound for one or more nodes` from the VPUX compiler; *after:* the actionable plugin-level message above.
- `clang-format-18` clean; function naming complies with the `ncc` style.

### Tickets:
- Closes #34617 — NPU `compile_model` fails for Qwen3-0.6B INT4 (unbounded dynamic shapes)
- Related: #32466, #24619, #26375, #26357 — same `INT64_MAX` / dynamic-shape root cause

### AI Assistance:
- AI assistance used: yes.
- How: AI (Claude Code; GitHub Copilot in earlier iterations) assisted with tracing the failure path through the NPU plugin, implementing `validate_no_unbounded_dynamic_dimensions` and the device-independent unit tests, and building the local verification harnesses.
- Human validation: the contributor directed and reviewed the change. It was validated locally from a from-source OpenVINO build on an Intel Core Ultra 7 258V (NPU 4000): the `ov_npu_unit_tests` `NPUUnboundedDynamicShape.*` suite (6/6), an on-device before/after of the real `compile_model("NPU")` path, a mutation test, and `clang-format-18`.
