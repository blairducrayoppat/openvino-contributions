@YuChern-Intel — thanks again for escalating this. I've pushed an update that addresses the main testability gap and hardens the guard:

- The check is now a device-free helper (`model_validation.{hpp,cpp}`) called from `Plugin::compile_model()`, with unit tests that exercise it **directly** — so they run on CPU-only precommit runners. The previous test compiled a model for `"NPU"` and `GTEST_SKIP()`'d when no device was present, so its assertions never actually ran in gating CI. The helper is wired into `ov_npu_unit_tests` via `OBJECT_FILES`.
- Added coverage for the output/result branch (unbounded output via `Range`), multi-input offending-name + dimension-index reporting, and the dynamic-rank early-return; de-duplicated the param/output message; and fixed the docs link (the previous `changing-input-shape.html` path returns 404 — now points to `model-preparation/setting-input-shapes.html`).
- Verified locally on an Intel Core Ultra 7 258V (NPU 4000): `ov_npu_unit_tests --gtest_filter=NPUUnboundedDynamicShape.*` → 6/6, plus an on-device before/after of `compile_model(<unbounded model>, "NPU")` (opaque `Missing upper bound for one or more nodes` from the VPUX compiler → actionable plugin-level message). The PR description has the full details.

Ready for CI / re-review whenever the team has a moment. Happy to adjust message wording, placement, or test structure.
