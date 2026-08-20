# npu_compiler source fix — UnrollGroupQuantize duplicate slice locations

**Status:** implemented, hardened after a 4-lens adversarial review, and verified locally (real model +
LIT regression test red-on-develop / green-with-fix). NOTHING POSTED TO GITHUB — this package is for Lead
Architect review. Branch `fix/unroll-group-quantize-duplicate-slice-locations` in
`C:/Users/mrbla/oss/npu_compiler`.

Repo note: `npu_compiler#NNN` = openvinotoolkit/npu_compiler; `openvino#NNNNN` = openvinotoolkit/openvino.

## 1. Scope first (the one-sentence version)

This fixes a **location-uniqueness invariant violation** in the `UnrollGroupQuantize` pass — it could emit two
`IE.Slice` ops with identical locations — which aborts compilation via `StopLocationVerifierPass`. It does
**not** change op semantics and does **not** enable any grouped-INT4 configuration on NPU.

## 2. The failure and its root cause

A grouped-INT4 LLM (Qwen3-0.6B, per-group `quant.uniform<u4:f16>` scale, NPUW static-LLM path) aborts with:

```
StopLocationVerifierPass Pass failed : Found 40 duplicated names after full verification
Failed to compile Model1106_kv1152_FCEW000__0 for all devices in [NPU]
```

This is the same failure Intel's own engineer reproduced on openvino#34450 (diego-villalobos) and on
openvino#35641 (dmfallak). The verifier is active in **stock release builds**, so this is a real user-facing
abort, not a developer-only check.

The compiler's own verbose duplicate report names the exact 40 collisions. The base is a weight-scale
`Parameter`, not the projection MatMul:

```
Found duplicated location 'Parameter_60752?t_Parameter/slice_0'.
  %32   = IE.Slice %arg10 [0,0,0] [1024,1,1]   (8 group-axis slices)
  %2097 = IE.Slice %arg10 [0,0,0] [1,8,1]      (1024 channel-axis slices)
```

| Colliding Parameter (a per-group scale) | suffixes | count |
|---|---|---|
| Parameter_60752 / _60755 / _60759 | slice_0..slice_7 | 8 each |
| Parameter_60763 | slice_0..slice_15 | 16 |

8+8+8+16 = **40**, exactly.

**Mechanism (traced in the pre-unroll IR):** in each grouped-INT4 attention projection, one per-group scale
`Parameter` is the dequantization scale of **two** `IE.DynamicDequantize` ops — the weight dequant
(`…/weight/fq_weights_1`) and the matmul dequant (`…/ov_ext::linear/MatMul`):

```
%…v_proj.weight/fq_weights_1   = IE.DynamicDequantize(%…v_proj.weight/fq_weights_1, %Parameter_60752)
%…v_proj/ov_ext::linear/MatMul = IE.DynamicDequantize(%…v_proj/…/MatMul,           %Parameter_60752)
```

`UnrollGroupQuantize::splitValue` located every produced slice as `appendLoc(val.getLoc(), "slice_{idx}", idx)`
— i.e. after the **shared scale value** plus only an index. Both consumers slice that scale (here along
different axes — 8/16 group slices vs 1024 channel slices), so the low indices `slice_0…slice_7/15` produced
byte-identical location strings. (The unrelated observation that ~10,285 ops share the q_proj MatMul *name* is
**by design** — `appendLoc` deliberately preserves the originating layer's name in every derived op's
metadata; the verifier does not object to that.)

## 3. The fix (one file, behavior-preserving)

`src/vpux_compiler/src/dialect/IE/transforms/passes/unroll_group_quantize.cpp`

`splitValue` now derives each slice's location from the **consuming op** plus an **operand-role tag** plus the
index, using the repo's `takeOpLoc` helper (the style guide mandates `takeOpLoc(op, …)` over
`appendLoc(op->getLoc(), …)`; `code_style.md:962`):

```cpp
// before:  appendLoc(val.getLoc(),                       "slice_{0}",        idx)
// after:   takeOpLoc(consumerOp, "{0}_slice_{1}", operandTag, idx)   // e.g. "scale_slice_0"
```

Callers pass the consuming op + a role tag: DynamicDequantize → `input`/`scale`/`zp`; FakeQuantize →
`data`/`in_low`/`in_high`/`out_low`/`out_high`. A slice is now `…/scale_slice_0` under consumer A vs the same
under consumer B but rooted at A's vs B's (unique) location — distinct per consumer, and per operand within a
consumer. This is the same idiom `ConvertGroupConvToConv` uses (`slice_in_{0}`, `weights_slice_{0}`). The
change touches only the `loc` argument of the created `IE.Slice` ops — no operands, attributes, types, or IR
structure — so it is behavior-preserving except for op locations. (The per-chunk FQ/DynamicDequantize *result*
ops keep their existing `slice_{idx}` location; they are one-per-consumer and unique by construction — noted in
a code comment so the asymmetry reads as intentional.)

## 4. Honest scope boundary

With the fix the same model passes the location verifier (40 → 0 duplicates) and then hits an unrelated,
pre-existing sub-byte lowering limit (`ConvertViewOpsToDeclarations: "Can't convert 4 Bit to Byte"`). This
patch neither addresses nor regresses that; the model still does not run end-to-end on NPU. **The fix is
orthogonal to the support status of any grouped-INT4 config** — it only removes a location-uniqueness
violation in the unroll pass. (Note on terminology: the IR that triggers the bug is symmetric scale-only `u4`
— every `DynamicDequantize` is 2-arg, no zero-point — so this is deliberately *not* framed around the
asymmetric-per-group-INT4 config that openvino#34450 closed as unsupported.)

## 5. Verification (all done on disk)

- **Real model:** `Found 40 duplicated names` → **0**; verifier passes; compile then fails later at
  `ConvertViewOpsToDeclarations`. (`clean_*.log` before, `fix_run_*.log` after.)
- **New LIT test** `unroll_group_quantize_shared_param_locations.mlir`: binds each slice to its `IE.Slice` op
  and asserts the location resolves to a consumer-rooted, operand-tagged fused loc (the
  `convert_assign_and_read_value.mlir` idiom), covering both scale and data slices, with metadata-bearing
  consumer locs matching importer IR. **Green on the fixed compiler; red on the unfixed compiler** — on the
  unfixed build the two consumers' scale slices genuinely collide (both resolve to the same loc), so FileCheck
  exits non-zero. **Confirmed on the committed test file:** against the unfixed compiler the two scale-slice
  ops both resolve to `#loc26` (and `#loc27`) — a real duplicate — the old form is `loc("slice_0")` with no
  `scale_slice_0` tag, and `FileCheck` exits 1. Against the fixed compiler the test passes. (Logs:
  `lit_v2_prefix_out.log` = unfixed run; the fixed-compiler pass was re-confirmed on the final `takeOpLoc`
  build.)
- **Existing tests:** `unroll_group_quantize.mlir` + `_50XX+.mlir` LIT and 5 `MLIR_LocationsVerifier` unit
  tests pass post-fix (loc-only change; the existing LIT files carry no `loc(...)` CHECKs).
- Built + run on NPU4000 (Lunar Lake), developer build with assertions; incremental rebuilds ~28s, throttled.

## 6. Recommended contribution path (LA decision)

andrey-golubev's actual review on **npu_compiler#266** (CHANGES_REQUESTED, 2026-04-17) was:

> "I believe the root cause here stems from the fact that an operation with zero-dim tensor exists at all …
> if zero-dim tensor comes from another compiler pass, this is where it has to be fixed."

That ask was about the **zero-dim tensor** (the original `as_convolution` crash), not this duplicate-location
failure. But (a) his **principle** — fix it in the pass where it appears — applies directly, and (b) on
current `develop` the zero-dim crash no longer reproduces; the failure has **shifted** to this duplicated-names
abort. So the honest framing cites his principle and the shift, and does **not** claim he asked for this exact
fix.

**Recommended (engagement-first):** post the §6a comment on npu_compiler#266 (where andrey-golubev is the
engaged reviewer), then open the §6b PR and link it. Alternative: open the PR directly and reference
#266 + openvino#34450/#35641. Also a real decision for you: #265/#266 are *your* open PRs proposing zero-dim
guards that andrey-golubev pushed back on and that no longer have a live reproducer on develop — worth
deciding whether to close/repoint them.

### 6a. Draft comment for npu_compiler#266 (NOT posted)

> @andrey-golubev — following your guidance here ("if it's a problem originating in a compiler pass, it has to
> be fixed in the place where such a [tensor] appears"), I rebuilt current `develop` (`30d2bb87b`) with
> assertions and traced what happens now.
>
> The zero-dim `as_convolution` crash this PR guards **no longer reproduces** on develop for the Qwen3-0.6B
> grouped-INT4 NPUW path — there is no `tensor<0x…>` anywhere in the pass dump. The failure has shifted to a
> location-verifier abort:
>
> ```
> StopLocationVerifierPass Pass failed : Found 40 duplicated names after full verification
> ```
>
> Root cause (from the verifier's own duplicate report): `UnrollGroupQuantize` names each unrolled slice after
> its *input value* (`appendLoc(val.getLoc(), "slice_{0}", idx)`). In each attention projection one per-group
> scale `Parameter` is the dequant scale of two `IE.DynamicDequantize` ops (weight dequant + matmul dequant);
> both are unrolled, so the shared scale's low-index slices get identical locations — the 40 duplicates the
> verifier reports. That is a pass emitting non-unique locations, i.e. the "fix where it appears" case you
> described.
>
> I have a one-file fix in `UnrollGroupQuantize` that locates each slice after its consuming op + an operand
> tag (the `takeOpLoc` convention `ConvertGroupConvToConv` uses), with a LIT regression test. With it the
> verifier passes (40 → 0); the model then hits an unrelated sub-byte lowering limit, so this is purely the
> location-uniqueness fix, not a support-enabling change. Shall I open it as a separate PR against `develop`
> and link it here? And since the zero-dim guard in this PR no longer has a live reproducer on develop, happy
> to close or repoint #265/#266 — whatever you prefer.

### 6b. Draft PR (NOT opened)

**Title:** `[IE] UnrollGroupQuantize: unique locations for unrolled slices of a shared value`

**Body:**

> **What.** `UnrollGroupQuantize::splitValue` located each unrolled `IE.Slice` after its *input value*
> (`appendLoc(val.getLoc(), "slice_{0}", idx)`). When one value (e.g. a grouped-quantization weight scale) is
> the input of more than one unrolled consumer, the low-index slices of the two consumers get identical
> locations. This patch locates each slice after its *consuming op* plus an operand-role tag
> (`takeOpLoc(consumerOp, "{0}_slice_{1}", operandTag, idx)`), the convention `ConvertGroupConvToConv` and
> other splitting passes already use. Loc-only change; op semantics unchanged.
>
> **Why.** A grouped-INT4 LLM (Qwen3-0.6B, per-group `u4` weights, NPUW static-LLM path) aborts with
> `StopLocationVerifierPass Pass failed : Found 40 duplicated names after full verification`. The 40 are
> `IE.Slice` ops from this pass: one per-group scale `Parameter` is the dequant scale of two
> `IE.DynamicDequantize` ops (weight + matmul dequant), both unrolled, so the shared scale's slices collide.
> The same `StopLocationVerifierPass` failure was reproduced on openvino#34450 and noted on openvino#35641.
> The verifier runs in release builds, so this aborts real compiles.
>
> **Scope.** Correctness fix for the location-uniqueness invariant only. It does not enable any grouped-INT4
> config on NPU: with the fix the model passes the verifier (40 → 0) and then hits an unrelated, pre-existing
> sub-byte lowering limit (`ConvertViewOpsToDeclarations: "Can't convert 4 Bit to Byte"`); it still does not
> run end-to-end on NPU. Orthogonal to support status.
>
> **Test.** `unroll_group_quantize_shared_param_locations.mlir` — two `DynamicDequantize` ops share one scale;
> binds each slice to its `IE.Slice` op and asserts a consumer-rooted, operand-tagged location, so the two
> consumers' slices are distinct. Red on develop, green with the patch. Existing
> `unroll_group_quantize.mlir` / `_50XX+.mlir` and `MLIR_LocationsVerifier` unit tests unaffected.
>
> **Validation.** Real model 40 → 0 duplicates; new LIT red-on-develop / green-with-fix; existing LIT + unit
> tests pass; built + run on NPU4000 (Lunar Lake).

**Per-claim verification status** (for LA confidence — every postable claim is backed):
- "Found 40 duplicated names", the 8+8+8+16 split, the two-consumer/shared-scale mechanism: VERIFIED (verbose
  report + pre-unroll IR).
- 40 → 0 after fix + later ConvertViewOpsToDeclarations failure: VERIFIED (fix_run_*.log).
- u4 scale-only / 2-arg dequant (no zp): VERIFIED (grep of reproducer_clean.mlir + tree dump).
- openvino#34450 reproduced-by-diego "Found 40 duplicated names": VERIFIED (his 2026-04-24 comment).
- andrey-golubev #266 quote: VERIFIED verbatim via api.github.com (reviews endpoint).
- LIT red-on-develop / green-with-fix: VERIFIED on the committed test (unfixed: scale slices collide on
  #loc26/#loc27, FileCheck exit 1; fixed: pass).
- Style-guide takeOpLoc rule (code_style.md:962): VERIFIED.

### Contribution-process checklist (CONTRIBUTING.md) — before posting
- [ ] PR from a fork (not a branch).
- [ ] Linked to the issue(s) with the scope restated.
- [ ] Validation results pasted into the PR body.
- [ ] Issue numbers qualified by repo on first use.
