# DRAFT v3 — comment for openvino PR #34651

Target: https://github.com/openvinotoolkit/openvino/pull/34651
Hardened after a 3-lens adversarial review (maintainer-skeptic / technical-accuracy / tone-strategy).

STATUS: v3 POSTED by Blair 2026-06-11 13:09 (comment id 4680901557). A clean, line-unwrapped version is below
under "FINAL CLEAN (unwrapped) — for edit-in-place"; content identical, only hard line breaks removed + code block
reflowed to avoid horizontal scroll.

## FINAL CLEAN (unwrapped) — for edit-in-place

Follow-up to my 2026-04-16 note. Stating the motivation concretely: on the optimum-intel / GenAI NPU export path, an unbounded-dynamic LLM currently dies with an opaque `to_shape was called on a dynamic shape` (an INT64_MAX-vs-INT64_MIN overflow in the compiler's broadcast analysis); this PR turns that into an actionable "reshape `input_ids` …" message.

I re-confirmed on current master (`e4e180d`, i.e. without this PR) that it still reproduces, and that the guard's predicate genuinely applies to a real export — every input parameter dimension is unbounded (`dim.is_dynamic() && !dim.get_interval().has_upper_bound()`), so the parameter/result check here fires. Minimal trigger via the in-plugin `compile_model` path (note `compile_tool` can't show it — its own up-front dynamism check rejects the model before the plugin runs):

```python
core.compile_model(core.read_model("qwen3-0.6b-int4/openvino_model.xml"), "NPU")
# on master (no guard): -> "to_shape was called on a dynamic shape"
# with this PR:         -> "NPU does not support models with unbounded dynamic dimensions.
#                           Parameter 'input_ids' ... model.reshape(...)"  (asserted by the unit test in this PR)
```

@YuChern-Intel, per your go-ahead on #34617 — when the team has a moment, could someone kick off CI and take a look? Happy to adjust the message wording or placement.

---

## POSTABLE TEXT (this is the only part that would go public)

---
Follow-up to my 2026-04-16 note. Stating the motivation concretely: on the optimum-intel / GenAI NPU export path, an
unbounded-dynamic LLM currently dies with an opaque `to_shape was called on a dynamic shape` (an INT64_MAX-vs-INT64_MIN
overflow in the compiler's broadcast analysis); this PR turns that into an actionable "reshape `input_ids` …" message.

I re-confirmed on current master (`e4e180d`, i.e. without this PR) that it still reproduces, and that the guard's
predicate genuinely applies to a real export — every input parameter dimension is unbounded
(`dim.is_dynamic() && !dim.get_interval().has_upper_bound()`), so the parameter/result check here fires. Minimal
trigger via the in-plugin `compile_model` path (note `compile_tool` can't show it — its own up-front dynamism check
rejects the model before the plugin runs):

```python
core.compile_model(core.read_model("qwen3-0.6b-int4/openvino_model.xml"), "NPU")
# master (no guard):  -> to_shape was called on a dynamic shape
# with this PR:        -> "NPU does not support models with unbounded dynamic dimensions. Parameter 'input_ids' …
#                          model.reshape(...)"   (this is what the unit test added in this PR asserts)
```

@YuChern-Intel, per your go-ahead on #34617 — when the team has a moment, could someone kick off CI and take a look?
Happy to adjust the message wording or placement.

---

## CHANGES FROM v2 (per adversarial review — all three reviewers agreed "post with edits", max severity minor)

1. **Honesty fix (high-confidence, the load-bearing one):** v2's "with this PR the same call instead raises the
   actionable message" implied a post-guard *run* that was never executed (the repro was on a guard-less master
   build). v3 attributes the post-guard behavior to "the unit test added in this PR asserts," not an implied live run.
2. **Dropped "matches the original driver-side trace in #34617"** — it contradicted the "in-plugin compiler" framing
   (same root cause, different trace/signature). v3 says "same predicate / still reproduces," no trace-equivalence claim.
3. **Removed "no driver involved"** — the captured trace contains `vcl*` (compiler-in-driver) symbols; a maintainer
   could nitpick. v3 just says "in-plugin `compile_model` path."
4. **Cut ~60% for length.** There is ALREADY an unanswered 2026-04-16 author ping on this PR; a second long re-paste
   reads as pestering. v3 references the prior note and adds only what's genuinely new (fresh-master reproduction +
   unbounded-predicate confirmation + the 1-line repro). Leads with user-impact, not the ping.
5. **Softened the CI ask** ("kick off CI" rather than "approve the workflow run") — could not confirm a run is
   actually sitting in an approval-required state.
6. **Kept verbatim** the strongest sentence (compile_tool-can't-show-it) — all reviewers said preserve it.

## VERIFICATION STATUS (every claim in the postable text)
- Params/results all unbounded-INT64_MAX: VERIFIED (diagnostic harness on master build).
- Guard predicate string matches PR diff char-for-char; guard iterates params+results only, before the compile step:
  VERIFIED (read the diff).
- master (`e4e180d`) lacks the guard: VERIFIED (grep).
- `core.compile_model` reproduces `to_shape`; `compile_tool` pre-rejects dynamic models: VERIFIED (two runs).
- Post-guard message wording: quoted from the PR's own throw + its gtest — NOT independently run (correctly attributed
  to the test, not claimed as observed).
- YuChern-Intel go-ahead quote: exact (API).

## STRATEGIC NOTE FOR LA (decision, not yet acted)
The PR's two prior author pings went unanswered, but the maintainer (YuChern-Intel) DID respond on the **issue
(#34617)**. Engagement-first suggests the highest-odds move is this tight comment **@-mentioning YuChern-Intel on the
PR** (puts the new evidence in front of the human who already engaged), and/or a one-liner on #34617 pointing here.
Avoid a third long un-referenced PR comment. Before posting, optionally check the PR's Actions tab for an
`action_required` CI run so the ask is precise.
