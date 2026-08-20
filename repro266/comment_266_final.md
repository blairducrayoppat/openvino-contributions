@andrey-golubev — following your guidance here ("if zero-dim tensor comes from another compiler pass, this is where it has to be fixed"), I rebuilt current `develop` (`30d2bb87b`) with assertions and traced what happens now.

The zero-dim `as_convolution` crash this PR guards **no longer reproduces** on develop for the Qwen3-0.6B grouped-INT4 NPUW path — there is no `tensor<0x…>` anywhere in the pass dump. The failure has shifted to a location-verifier abort:

```
StopLocationVerifierPass Pass failed : Found 40 duplicated names after full verification
```

Root cause (from the verifier's own duplicate report): `UnrollGroupQuantize` names each unrolled slice after its *input value* (`appendLoc(val.getLoc(), "slice_{0}", idx)`). In each attention projection one per-group scale `Parameter` is the dequant scale of two `IE.DynamicDequantize` ops (weight dequant + matmul dequant); both are unrolled, so the shared scale's low-index slices get identical locations — the 40 duplicates the verifier reports. That is a pass emitting non-unique locations, i.e. the "fix where it appears" case you described.

I have a one-file fix in `UnrollGroupQuantize` that locates each slice after its consuming op + an operand tag (the `takeOpLoc` convention `ConvertGroupConvToConv` uses), with a LIT regression test. With it the verifier passes (40 → 0); the model then hits an unrelated sub-byte lowering limit, so this is purely the location-uniqueness fix, not a support-enabling change. Shall I open it as a separate PR against `develop` and link it here? And since the zero-dim guard in this PR no longer has a live reproducer on develop, I'm happy to close or repoint #265/#266 — whatever you prefer.

---

*AI assistance disclosure (per the OpenVINO AI Usage Policy): a coding agent (Claude, via Claude Code) helped trace this failure on a local developer build, identify the root cause, draft the fix and its LIT regression test, and draft this comment. Every result quoted above — the duplicate-name report, the 40 → 0 verifier outcome, and the red-on-`develop` / green-with-fix test runs — was produced by building and running the compiler locally on Intel NPU (Lunar Lake) and was reviewed by me before posting.*
