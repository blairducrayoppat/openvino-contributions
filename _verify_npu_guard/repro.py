"""Reproduce the original opaque NPU error for unbounded dynamic shapes (the bug the
guard replaces) and cross-check the predicate semantics against the real OV Dimension API."""
import openvino as ov

print("OV version:", ov.__version__)
core = ov.Core()
print("devices:", core.available_devices)

# Build a model with a fully unbounded dynamic dimension (like an LLM export).
p = ov.op.Parameter(ov.Type.f32, ov.PartialShape([1, -1, 64]))
p.set_friendly_name("input_ids")
model = ov.Model([p.output(0)], [p], "unbounded_test")

print("\n--- predicate cross-check (real ov.Dimension API) ---")
def describe(shape, label):
    for i, d in enumerate(shape):
        print(f"  {label} dim[{i}]: is_dynamic={d.is_dynamic} "
              f"min={d.get_min_length()} max={d.get_max_length()}")

describe(ov.PartialShape([1, -1, 64]), "unbounded ")
describe(ov.PartialShape([1, ov.Dimension(1, 512), 64]), "bounded   ")
describe(ov.PartialShape([1, 3, 64]), "static    ")

print("\n--- reproduce NPU compile failure on real hardware ---")
try:
    cm = core.compile_model(model, "NPU")
    print("UNEXPECTED: compiled without error")
except Exception as e:
    print("NPU compile raised:", type(e).__name__)
    print(str(e)[:600])
