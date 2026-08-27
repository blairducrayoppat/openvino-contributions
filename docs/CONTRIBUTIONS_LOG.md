# Contributions Log

Narrative/evidence trail for Blair's upstream open-source work: what was found, how it was
verified, with numbers. This is the record his professional portfolio and AIGP (AI Governance
Professional) certification evidence draws on — write for a reader who wasn't in the room.

The live *queue* (what's next, current status) is Vikunja project **"OSS Contributions" (id
11)**, not this file — don't duplicate one into the other; this file explains, the queue tracks.

Every entry: dated header, what happened, verification methodology + exact numbers, links,
current status. Update at every state change, not just at the end.

---

### 2026-08-19 — Workspace given its own CLAUDE.md, agent, and git history

*Plain summary: this folder went from an undocumented pile of build scripts and checkouts to a
self-contained, doctrine-carrying workspace — and a memory-recalled track record turned out to
have drifted from live GitHub state on two items.*

Blair pointed out this folder had no README and no agentic-development scaffolding, despite
holding real, active upstream work. Built: `README.md` (directory map + live state),
`CLAUDE.md` (self-contained doctrine — engagement-first, verification discipline, standing
workflows, git discipline; does not inherit another workspace's CLAUDE.md since Claude Code loads it
per-directory-tree), `.claude/agents/upstream-contributor.md` (a dedicated subagent for the four
recurring asks: GitHub-link triage, live-bug-to-ticket, feature-request drafting, Lunar Lake
hardware testing), this log, and a `.gitignore` that separates the meta-layer (docs, scripts,
curated evidence — tracked) from the upstream checkouts (`openvino/`, `openvino.genai/`,
`openvino.genai-pr-worktree/`, `npu_compiler/` — each keeps its own independent git history,
gitignored here). `oss/` itself is now a git repo for the first time (local only, no remote).

**Track record re-verified live via `gh api` before writing it down** (a prior memory summary
was 28+ days stale and wrong on two of these):

| Item | Memory said | Live GitHub state (checked 2026-08-19) |
|---|---|---|
| `openvino.genai#4082` | merged 2026-07-08 | confirmed: merged, `merged_at` 2026-07-08T13:07:36Z |
| `openvino#34651` (NPU dynamic-shape guard) | "stalled at last check" | **closed** 2026-07-30T00:38:15Z (`state_reason` not recorded as a decline — resolution mechanism, e.g. which PR closed it, not yet traced; check before citing as a second merged fix) |
| `openvino#35641` (NPU INT8 weight-only crash) | open, filed | **closed 2026-06-19, `state_reason: not_planned`** — this was declined, not fixed; do not describe it as a win |
| `npu_compiler#265` | filed | closed 2026-06-19 |
| `npu_compiler#266` | filed | closed 2026-06-19 |
| `openvino.genai#4139` (thinking/reasoning-budget config, Vikunja #923) | open, unmerged | confirmed: still open, unmerged — check-back was already flagged overdue since 2026-07-30 |
| `openvino.genai#4091` (persistent KV-cache feature request, Vikunja #710) | open | confirmed: still open |

**Two loose ends flagged, not resolved, in this pass** (owned by whoever next touches these
checkouts — see `README.md` for detail):
1. `openvino.genai/` has uncommitted local changes on `releases/2026/2` (`CMakeLists.txt`,
   `xgrammar_backend.cpp`, a dirty `thirdparty/openvino_tokenizers` submodule pointer) — origin
   not inventoried.
2. `openvino.genai-pr-worktree/` (branch `fix/xgrammar-stop-token-spec-decode`, the source of
   the now-merged #4082) has a local HEAD that no longer matches what's pushed to the `fork`
   remote — diverged, not reconciled. Should be cleaned up once inventoried, not before.

**Trade-off:** did not attempt to trace exactly which PR closed `openvino#34651`, and did not
touch the two uncommitted/diverged git states above — both would have required either more
`gh api` calls of uncertain value or git operations on live contribution branches, and neither
was necessary to deliver what was asked (the workspace scaffolding itself). Named here so the
gap is visible rather than silently absorbed into a "track record verified" claim.

**Next:** decide whether `openvino#34651`'s closing PR is worth citing in future engagement
comments (needs tracing first); inventory and reconcile the two flagged git states before either
checkout is built on top of again.

---

### 2026-08-19 — `openvino.genai#4139` check-back (Vikunja #923), 19 days past trigger

*Plain summary: the "am I owed anything on this thread" check came back no. The maintainer left
four code-design requests aimed at the PR author's implementation, not at Blair, and the author
hasn't caught up yet — nothing to test, nothing to post. Vikunja task #923 updated in place
(comment + due date pushed to 2026-08-25); nothing posted externally.*

Vikunja task #923 set a 2026-07-30 check-back trigger on `openvino.genai#4139` (the
`enable_thinking`/`reasoning_budget_tokens` PR) with an explicit decision tree: if
author/maintainers are engaged, test their next iteration on hardware and report back
(LA-held); if the thread stalls ~2 weeks or the maintainer declines the template-level
direction, propose a separate PR instead. That trigger sat unactioned for 19 days.

**Live state pulled via `gh api`** (issue comments, `pulls/4139/reviews`,
`pulls/4139/reviews/{id}/comments` for inline threads, `pulls/4139/comments`,
`actions/runs?head_sha=...` for real CI status, `pulls/4139/commits`) — not WebFetch.

- **Decision-tree read: author/maintainer-engaged branch, not stalled.** Thread had continuous
  back-and-forth through 2026-07-24 (Blair ↔ PlanteAmigor, the PR author), then the assigned
  maintainer `apaniukov` left 4 inline review comments on 2026-08-11 — 8 days before this check,
  short of the ~2-week stall threshold measured from that date.
- **apaniukov's 4 comments (2026-08-11, commit `06466bfc33`), all directed at PlanteAmigor's
  code, none @-mentioning Blair:**
  1. "Auto-detection should be implemented on C++ side, not just in python."
     (`src/python/py_llm_pipeline.cpp`)
  2. "Better to group into one `ReasoningConfig`, similar to `StructuredOutputConfig` and make
     it optional. No need for `bool enable_thinking` parameter, `budget = 0` is enough to
     disable thinking if needed." (`generation_config.hpp`) — an API-shape redesign request.
  3. "Use `IStatefulLogitTransformer` instead of `ILogitTransformer`." (`logit_transformers.hpp`)
  4. "And it also can be registered via `m_stateful_logit_transformers`."
     (`logit_transformers.hpp`)
- **No commits since `06466bfc33` (2026-07-24)** — PlanteAmigor has not yet implemented the
  redesign, so there is no new iteration to build-from-source and re-test on Arc 140V.
- `mergeStateStatus: BEHIND` (base moved on), `reviewDecision: REVIEW_REQUIRED` — unchanged,
  not urgent on its own.
- **Real CI has never run on this PR.** Linux/Windows/macOS/Lint/Manylinux/SDL checks all sit
  at `action_required` (GitHub's fork-PR gate) since PR creation 2026-07-11 — only the trivial
  PR-labeler check has ever completed. This needs an org maintainer's manual Actions approval;
  not actionable by Blair or PlanteAmigor.
- Blair's own open scope question from 2026-07-23 (whether `reasoning_budget_tokens > 0` is
  meant to be supported on the VLMPipeline non-chat path, explicitly deferred to apaniukov) is
  still unanswered as of this check.

**Verification note:** this was a read-only state check — no build, no reproduction run, no
external post. Nothing required Blair's decision today (no scope change, no
abandon/redirect ask, no public-posture question); the two live open items (the redesign
request and the unanswered VLM-path scope question) are PlanteAmigor's/apaniukov's to move,
not Blair's.

**Vikunja task #923 updated:** posted a comment (id 3215) with the above findings; due date
moved from 2026-07-30 to **2026-08-25** (~2 weeks from apaniukov's 2026-08-11 engagement — the
trigger the task's own decision tree keys on). One correction during this update: a
`POST /tasks/923` call sent with only `due_date` briefly wiped the task's title/priority/
description (Vikunja's update endpoint replaces the full task rather than merging) — caught
immediately via the pre-edit backup and restored in a follow-up call; verified by re-GET
afterward (description length 1338 chars, priority 2, comment count 1, all intact). Named here
so the correction is visible rather than silently absorbed.

**Access note:** the Vikunja MCP tools listed in this session's allowed-tools
(`mcp__vikunja__get_task`, `search_tasks`, `project_summary`, `list_task_comments`,
`list_projects`) were not connected/discoverable this session (`ToolSearch` found nothing for
any of them). Fell back to the project-management tool's REST API directly via its documented URL/token
environment variables, already present in the environment for this purpose — same
underlying system, no new credential was created or entered anywhere. Worth noting for whoever
next expects the MCP tools to "just work" in this workspace.

**Next:** re-check around 2026-08-25, or sooner if PlanteAmigor pushes the `ReasoningConfig`/
`IStatefulLogitTransformer` refactor — that would be the next thing to build from source and
re-test on Arc 140V per the standing offer already on the thread.

---

### 2026-08-19 (addendum) — precise impact of the 4 review comments on Blair's own commit

*Plain summary: Blair asked specifically whether HE needs to update anything he contributed —
not just "is it aimed at PlanteAmigor." Traced it down to the exact file/line level. Answer:
nothing to change today, but one of the four requests is a real, specific future risk to
Blair's tests, flagged below so it isn't missed when PlanteAmigor's next commit lands.*

**What Blair actually contributed to this PR:** exactly one commit, `f90cc875` (2026-07-23,
verified via `commit.author.name`/`email` = `mr.blair.do@gmail.com` and GitHub `login=
blairducrayoppat`, the only commit on the branch not authored by PlanteAmigor/`Amigor`).
It touches exactly one file: `tests/cpp/logit_filtering.cpp` (+203 lines, 0 deletions) — unit
tests for `ThinkingBudgetTransform`'s prompt-scan state machine (IDLE/COUNTING/FORCING/DONE).

**Cross-referenced against apaniukov's 4 live comments (path + line, via
`pulls/4139/comments` diff_hunks, confirmed still unresolved/current via GraphQL
`reviewThreads`):**

| # | Request | File:line | Touches Blair's file? |
|---|---|---|---|
| 1 | Move auto-detect to C++ | `src/python/py_llm_pipeline.cpp:81` | No — different file entirely |
| 2 | Consolidate into `ReasoningConfig` | `generation_config.hpp:709` | No — public config struct, not the transform class Blair's tests construct directly |
| 3 | Use `IStatefulLogitTransformer` base | `logit_transformers.hpp:545` | Not directly (different file) — but see risk below |
| 4 | Register via `m_stateful_logit_transformers` | same thread as #3 | Same as #3 |

(Two earlier apaniukov comments on this same class, from 2026-07-22/23, are confirmed
`isResolved: true` via GraphQL — already addressed by PlanteAmigor's `cea6c5f2` commit before
Blair's tests were even added. Not live, excluded above.)

**No line Blair wrote is the target of any of the four comments** — his tests file was never
reviewed by apaniukov. Nothing needs to change in `tests/cpp/logit_filtering.cpp` today, and
the PR still builds/passes as-is.

**Real risk identified, not yet realized:** request #3 asks to change
`ThinkingBudgetTransform`'s base class from `ILogitTransformer` to `IStatefulLogitTransformer`.
Pulled the actual interface (`logit_transformers.hpp:84-86` at head `06466bfc`):
`IStatefulLogitTransformer` requires overriding `accept_tokens(const TokenIds& input_ids)`
(plural, a vector) — but `ThinkingBudgetTransform::accept_token(int64_t token_id)` (singular,
one id at a time) is the actual current method, and it's what **every one of Blair's 11 unit
tests calls directly**, many times each, to simulate one-token-at-a-time generation. If
PlanteAmigor implements request #3 literally and the singular `accept_token` goes away or
changes shape, Blair's tests will fail to compile and need updating to match whatever the new
interface becomes.

**Recommendation:** don't preemptively rewrite Blair's tests now — there's no real
implementation yet to target, and guessing at PlanteAmigor's exact refactor shape would be
speculative work. Instead, this is now a named watch item: when PlanteAmigor's next commit
lands (tracked by the 2026-08-25 check-back above), the first thing to check is whether
`ThinkingBudgetTransform::accept_token` still exists with its current signature before
assuming Blair's tests still pass.

---

### 2026-08-19 (later same day) — offered to implement the `IStatefulLogitTransformer` swap on `openvino.genai#4139`, two posting mishaps corrected

*Plain summary: decided offering to do the maintainer-requested base-class swap (not just
retest) was appropriate and not "steamrolling" the student author, since it's mechanical,
maintainer-specified, and touches Blair's own tests either way. Posting it went wrong twice —
a corrupted first comment, then a formatting-defective manual repost — both caught fast and
fixed. No technical claim in the final comment was wrong; both mishaps were mechanical/tooling
failures, not review failures.*

**Etiquette research before drafting anything:** read `.github/CONTRIBUTING.md` in full
(openvino.genai) — confirmed no sanctioned private channel exists (no Discord/Slack/mailing
list), so DMing either PlanteAmigor or apaniukov was ruled out in favor of staying on-thread.
Read `AI_USAGE_POLICY.md` (openvinotoolkit/openvino, linked from CONTRIBUTING.md) in full —
Blair's per-comment AI-disclosure practice on this thread already meets it.

**Technical claim verified against source before drafting, not assumed:** read
`logit_transformers.hpp` and `logit_processor.hpp` at head `06466bfc33` directly. Confirmed the
swap really is mechanical: `IStatefulLogitTransformer` needs only one additional override,
`accept_tokens(const TokenIds&)`; `ThinkingBudgetTransform` already implements `apply()` and
`is_applicable()`; the generic `m_stateful_logit_transformers` loop already calls
`accept_tokens({new_token_id})`, and `m_thinking_budget` is assigned in exactly one
null-guarded constructor branch, so registering it there carries no null-pointer risk. An
independent `upstream-review` skill pass caught one real over-claim before it went out — an
earlier draft said Python config-test coverage was "a bit thin," which the actual PR diff
disproved (13 lines already covered exactly that gap) — corrected before posting, not after.

**Posted comment** (final approved text, offering to do the `IStatefulLogitTransformer` +
`m_stateful_logit_transformers` swap and update Blair's 11 tests in `logit_filtering.cpp`
together, plus the standing Arc 140V retest offer and AI-disclosure line):
https://github.com/openvinotoolkit/openvino.genai/pull/4139#issuecomment-5342341547

**Two mishaps, both corrected same-session:**
1. Delegated posting via `gh api issues/4139/comments -f body=@<file>`; the substitution didn't
   behave as expected and the literal file path string was posted as the comment body — visible
   publicly on a thread a maintainer and a student author both watch. Caught immediately by
   Blair from the live page; he deleted it himself (comment id 5342306563) before an API delete
   call completed (confirmed 404 — already gone). The still-running posting agent was killed to
   stop it writing false "success" state anywhere.
2. Blair then posted the comment manually himself (id 5342341547) — content correct, but all
   backtick code-formatting was missing. Fixed via `gh api -X PATCH` on the same comment id
   (edited in place, not deleted/reposted) — PowerShell `ConvertTo-Json` used to build the JSON
   payload after `jq` proved unavailable in this environment's Bash. Verified byte-for-byte
   against the live API response after the edit; the only diff was a trailing-newline artifact,
   not a content difference.

**Trade-off:** did not re-verify the SHA `06466bfc33d398c6796e7d23d9f6345f834c7401` a third time
immediately before the corrected PATCH — it was already checked twice earlier in the same
session and the PR had no new commits in between (confirmed via the same `pulls/4139/commits`
check used for the 2026-08-25 check-back above).

**Standing rule this establishes:** never claim a post succeeded without fetching it back from
the API and diffing against the intended source text — assumed-success was exactly what caused
mishap 1 to go unnoticed for as long as it did.

**Next:** awaiting PlanteAmigor/apaniukov response to the offer; still folds into the existing
2026-08-25 check-back trigger on Vikunja #923 — no new trigger needed.

---

### 2026-08-19 (later still) — compiled-assets inventory: what's already built from scratch in this workspace

*Plain summary: Blair asked what's already compiled here that would speed up future
contribution work, prompted by scoping a possible OVMS (model_server) hardware-testing
contribution. Answer: a real, working native-Windows OpenVINO + OpenVINO GenAI build already
exists, with GPU plugin support, and — usefully — the GenAI checkout happens to sit at exactly
the 2026.2.1 release commit that one live OVMS bug report (`model_server#4428`) is filed
against. But it does NOT shortcut an OVMS build itself: OVMS's own Windows build script always
manages its own OpenVINO copy (downloads a pinned prebuilt package by default, or clones+builds
fresh into its own directory if source mode is forced) — there is no supported way to point it
at an arbitrary local install. The existing build's real value is direct GenAI-level
reproduction work, not OVMS compilation.*

**Verified by reading actual build-status marker files and `git log`/`git status` in each
checkout** (not assumed from file presence — `*_STATUS.txt` markers only get their final line
written on a real exit-0 completion):

| Checkout | HEAD commit | Branch | Working tree | What's built | Measured wall-clock |
|---|---|---|---|---|---|
| `openvino/` | `e4e180d1` (2026-03-18) | detached | clean | Runtime core, native Windows MSVC, RelWithDebInfo, x86_64 | configure 06-10 18:55→18:57 (~2 min), build →20:38 (**~1h41m** total) |
| `openvino/` (GPU plugin) | same | — | — | GPU plugin (Arc-class iGPU/dGPU) | 07-06 15:43→16:23 (**~40 min**) |
| `openvino/` (Python bindings) | same | — | — | `openvino` Python wheel/bindings | 07-06 17:26→17:30 (**~4.5 min**, incremental against already-built core) |
| `npu_compiler/` (via `openvino/`) | `4983451` (2026-06-19, on `fix/unroll-group-quantize-duplicate-slice-locations`) | — | clean | NPU compiler | configure 06-10 20:54→20:57, build →06-11 00:41 (**~3h43m**, the heaviest single build here) |
| `openvino.genai/` | `7dea0459` (2026-06-09, "Bump product version to 2026.2.1") | `releases/2026/2` | **3 uncommitted changes** (`CMakeLists.txt`, `xgrammar_backend.cpp`, dirty `openvino_tokenizers` submodule pointer — flagged, not yet inventoried, in the 2026-08-19 workspace-setup entry above) | C++ samples (incl. GPU) | 07-06 16:38→16:45 (**~7 min**) |
| `openvino.genai/` (Python bindings) | same | — | same caveat | GenAI Python bindings | 07-06 17:34→17:36 (**~2 min**, incremental) |
| `openvino.genai-pr-worktree/` | `4c797722` (2026-07-05) | `fix/xgrammar-stop-token-spec-decode` | clean | Source of the now-merged `#4082` fix; separately flagged as diverged from its `fork` remote in the workspace-setup entry above | not separately timed |

**What this means for OVMS work specifically:** read `docs/build_from_source.md`,
`windows_developer_guide.md`, and `windows_install_build_dependencies.bat` from
`openvinotoolkit/model_server` directly (not summarized from memory). OVMS's Windows build
defaults to `OV_USE_BINARY=1`, which downloads a pinned prebuilt OpenVINO GenAI package into its
own `C:\opt\openvino` tree — it does not build OpenVINO at all in the default path, and there is
no parameter to substitute an existing local install. Forcing `OV_USE_BINARY=0` instead
clones+builds fresh OpenVINO/tokenizers/GenAI from source into a separate managed directory —
also independent of anything already built here. Either way, the existing `openvino/` /
`openvino.genai/` builds above are not directly consumable by an OVMS build. Vendor-documented
number for the OVMS compile step itself (`windows_build.bat`, OpenVINO already resolved by
whichever of the two paths above): **"up to 1h depending on host CPU and internet connection
speed"** — no vendor number given for the dependency-install step, which itself builds OpenCV
from source and downloads ~6GB, so total first-time wall-clock is this session's own estimate,
not a cited fact.

**The higher-value path this inventory actually points to:** the OVMS maintainer on
`model_server#4428` said the *ideal* reproducer is at the GenAI level, not OVMS — and
`openvino.genai/` is already built with GPU support at the exact `2026.2.1` commit the bug
report cites, at **zero additional build time**, *if* the 3 uncommitted changes on that checkout
are first identified and either stashed or reconciled (using a dirty tree to reproduce an
upstream bug would undermine the verification discipline — the reproduction needs to be
attributable to a known, clean commit).

**Trade-off:** did not attempt to identify or resolve the 3 uncommitted `openvino.genai/`
changes in this pass — that's a prerequisite for using this checkout as a clean 2026.2.1
reproducer, not yet done. Did not verify GPU plugin functional correctness (only that the build
completed) — first real use will be the actual test.

**Next:** before attempting a `model_server#4428` GenAI-level reproducer on this checkout,
inventory and resolve the 3 uncommitted changes (diff them, decide stash vs. discard vs. keep,
confirm against `releases/2026/2` origin) so the reproduction stands on a known-clean commit.

---

### 2026-08-19 (later) — model_server#4428: GenAI-level reproducer built, one hypothesis in the issue thread corrected, a related-but-not-identical crash signature found

*Plain summary: mzegla asked for a synthetic GenAI-level reproducer of the OVMS #4428 crash plus
a linear-attention-vs-standard-SDPA comparison. Before building anything, re-reading the full
thread (not just the latest comments) showed the issue's own title is stale — the original
"client disconnect" trigger was withdrawn by the reporter three weeks ago. Built the reproducer
against the corrected (KV-cache-exhaustion) hypothesis instead. Did not reproduce the exact
reported crash, but found a closely-related, deterministic block-accounting leak in the same
code path, with a clean data pattern across 48 trials worth reporting as-is.*

**Correction caught before building anything (would have wasted the whole session on the wrong
target).** The issue title still reads "streaming client disconnects mid-generation", but
reporter lusoris explicitly withdrew that trigger in a 2026-08-04 comment: they patched their
proxy to stop disconnects from cancelling the upstream generation, and the server "still crashed
with the identical assertion." The confirmed trigger, from their own instrumented logs, is KV-
cache exhaustion under a **static** cache (`--cache_size 4` + `--max_num_seqs 16`, cache fills to
100%, a new request forces preemption, block manager asserts on a sequence whose blocks it already
freed). mzegla's most recent comment (2026-08-19T12:11:53Z) confirms this framing explicitly
("static cache size should also work without the crash, so I would stay focused on that known
failing case") and asks for (1) a GenAI-level synthetic reproducer and (2) a check against other
models — "older models like qwen3 coder or gpt-oss" — to see if the bug is linear-attention-
specific, "since block manager flow differs depending on attention type." Flagged this correction
to the team-lead immediately rather than building the disconnect reproducer the original brief
called for.

**Environment.** Windows 11 Pro, Intel Core Ultra 7 258V (Lunar Lake), Arc 140V (Xe2) iGPU,
driver **32.0.101.8826** (2026-05-28). `openvino-genai==2026.2.1.0` (official PyPI wheel — exact
version match to the issue; win_amd64 available). Used the wheel rather than a from-source build:
this workspace's local `openvino/` checkout self-reports `2026.2.1-...` per its own package
config but `openvino.genai`'s CMake version-compatibility check only accepts a requested version
≤ its own, and rebuilding to an exact matching commit would have cost ~1h41m (core) + ~40min (GPU
plugin) per the 2026-08-19 compiled-assets inventory above, for no citability benefit over the
official wheel. `pip show`: `openvino 2026.2.1`, `openvino-genai 2026.2.1.0`, `torch
2.13.0+cpu`, `transformers 4.57.6`, `optimum 2.3.0`, `optimum-intel 2.1.0` (transformers pinned
down from the initially-installed 5.5.4 — optimum-intel 2.1.0, the latest release, caps
`qwen3_next` export at transformers ≤4.57.6).

**Hygiene first.** `openvino.genai/`'s 3 uncommitted changes (flagged in the entry above,
untouched since) were `git stash push`-ed — one stash in the parent repo for `CMakeLists.txt` +
`src/cpp/src/sampling/structured_output/xgrammar_backend.cpp` (the latter confirmed functionally
identical to the already-merged `#4082` fix), one stash inside the `openvino_tokenizers`
submodule for its own matched `CMakeLists.txt` override. `git status` clean in both after.
Neither the from-source checkout nor the stashed changes were used for this reproduction — the
PyPI wheel in a fresh venv was — so this doesn't even touch that question of clean-commit
attribution.

**Reproducer design.** Read the actual assertion site in the `openvino.genai` checkout (pinned to
`7dea0459`, "Bump product version to 2026.2.1" — the exact commit the issue's `2026.2.1` targets):
`block_manager.hpp:633` is inside `free_group_partially()`, called from `scheduler.hpp`'s
`_apply_preemption -> _preempt_by_recompute` — the preemption/eviction path, confirming the
cache-exhaustion hypothesis at the code level independent of the reporter's own diagnosis.
`openvino_genai.ContinuousBatchingPipeline`'s Python API (`add_request`/`step()`/`get_metrics()`)
exposes exactly the fields the OVMS log lines use (`requests`, `scheduled_requests`,
`cache_usage`), so drove that directly rather than the OVMS server.

Built two tiny (~21-22M param), architecture-matched, randomly-initialized models sharing the
same tokenizer (real Qwen3-Next tokenizer, downloaded standalone — not the pretrained weights),
hidden_size=128, 8 layers, 4 attention heads / 2 KV heads, to isolate attention type as the one
variable: **(A) hybrid** — real `transformers.Qwen3NextConfig`/`Qwen3NextGatedDeltaNet` class
(the architecture behind Qwen3.6's Gated DeltaNet linear attention — confirmed via the real
Qwen3.6 architecture description found this session: 4:1 linear:full-attention ratio, matching
the original report's own "16 full-attention layers" / "~151MB per-slot linear-attention state"
math), MoE disabled (`num_experts=0`); **(B) standard** — dense `Qwen3Config`, standard SDPA only,
otherwise identical dimensions. **Finding along the way:** a MoE-enabled version of model (A)
fails to run on GPU at all in this GenAI build — `Operation: ...mlp/aten::add/Add of type
MOE(extension) is not supported` on the `intel_gpu` plugin — unrelated to the KV-cache bug, noted
for the draft comment, not otherwise investigated.

**Stress methodology.** `SchedulerConfig` with `cache_size=1` (int GB — the Python binding only
accepts whole GB, so 1 is the minimum nonzero/"static" value) or `num_kv_blocks` set directly for
finer control, `max_num_seqs=16`, `enable_prefix_caching=False` (turned off after an early test
showed it suppressed cache pressure entirely against a small repeated-prompt pool — a test
artifact, not a real finding, but not chased further this session). 120 concurrent long-generation
requests (`ignore_eos=True`, 200-1500 tokens, seeded `do_sample=True`) added across 10 staggered
waves against already-running sequences, `step()` called synchronously in a single Python thread
(no attempt to reproduce a concurrency/thread-timing component, if one exists beyond the
scheduling logic itself — named explicitly as untested below).

**Results — N=8 trials per (model × device × cache-setup), 48 trials total, exact counts:**

| model | device | cache setup | crashed (hard `OPENVINO_ASSERT`) | leaked block state on teardown | drained naturally within 6000 steps |
|---|---|---|---|---|---|
| hybrid (linear-attn) | CPU | cache_size=1 | 0/8 | **8/8** | 0/8 |
| hybrid (linear-attn) | GPU | cache_size=1 | 0/8 | **8/8** | 0/8 |
| standard (SDPA) | CPU | cache_size=1 (nominal, matched *settings*) | 0/8 | 0/8 | 8/8 |
| standard (SDPA) | CPU | num_kv_blocks=64 (tuned to match hybrid's 100% cache *pressure*) | 0/8 | **8/8** | 0/8 |
| standard (SDPA) | GPU | cache_size=1 (nominal, matched settings) | 0/8 | 0/8 | 8/8 |
| standard (SDPA) | GPU | num_kv_blocks=64 (matched pressure) | 0/8 | 0/8 | 8/8 |

Zero of the 48 trials hit the exact reported assertion. But **the "leaked block state" and "did
not drain within the 6000-step budget" columns correlate exactly, in all 6 configurations** — the
leak (`[ERROR] BlockManager leaked sequence block tables: N...` / `[ERROR] BlockAllocator leaked
blocks...` from `~BlockManager()`/`~BlockAllocator()`'s own destructor sanity checks) only ever
fired in trials that got stuck in sustained 100% cache saturation and never finished processing
all 120 requests; every trial that drained cleanly was clean. Leaked sequence counts (3-16 out of
120 per trial) and first-leaked-sequence-id are **identical across CPU and GPU at a matched random
seed**, and identical whether the hybrid model has MoE enabled or not (this pattern first showed
up in an earlier calibration run against the MoE-enabled hybrid variant, before the GPU MOE-op gap
above was found and the dense-FFN variant was built) — consistent with a deterministic scheduler-
logic defect, not a hardware- or thread-timing race.

So the practical difference between the two architectures, under this test, was not "leaks in
principle vs. doesn't" — it's that **the hybrid model reached the stuck/leaking state on both CPU
and GPU under the exact nominal settings the original report used** (`cache_size=1`, the same
class of settings as the report's `--cache_size 4`), while **the standard model only reached it
on CPU, and only once cache pressure was deliberately tuned to match** (`num_kv_blocks=64`) — at
matched nominal settings the standard model comfortably drained every trial (max ~12-14% cache
usage vs. the hybrid model's 100%). Best current read (not verified further): the hybrid model's
linear-attention state pre-commit makes it far more cache-expensive per token even before real KV
accumulates, so it reaches saturation "for free" at settings that don't stress a standard model at
all — matching lusoris's own per-slot-cache-cost math in the issue thread. The standard model
never leaked on GPU even at matched pressure (0/8) — those trials drained in under 2000 steps
every time, vs. CPU never draining within 6000 — consistent with (not proven to be caused by) GPU
being fast enough to clear the backlog before whatever accumulates into the leak has a chance to.

**Verification of the negative (no exact-assertion crash).** Confirmed the harness would have
caught the real assertion if it fired: `OPENVINO_ASSERT` failures surface to Python as a plain
`RuntimeError` (checked directly against a known-failing call), and the trial driver's `except
Exception` catches and records exactly that. So the "0/48 hard crashes" result is a genuine
negative, not a blind spot in the harness.

**Draft comment:** `C:\Users\mrbla\oss\scratch_ovms4428\draft_comment_4428.md` — NOT posted.
States all of the above, the exact numbers, what wasn't tested, and an AI-assistance disclosure
per this workspace's non-negotiable floor. Awaiting Blair's independent review.

**Reproducer scripts and raw logs (all local, not committed anywhere):**
- `C:\Users\mrbla\oss\scratch_ovms4428\build_models.py` — builds both tiny synthetic HF models
- `C:\Users\mrbla\oss\scratch_ovms4428\stress.py` — the trial driver (staggered-wave stress test)
- `C:\Users\mrbla\oss\scratch_ovms4428\calibrate.py` — early single-request cache-pressure calibration
- `C:\Users\mrbla\oss\scratch_ovms4428\logs_{cpu,gpu}_{hybrid,standard,standard_hard}.txt` — raw
  per-trial output for all 48 trials
- `C:\Users\mrbla\oss\scratch_ovms4428\models\ov-tiny-qwen3next-hybrid-dense`,
  `ov-tiny-qwen3-standard` — the two exported OpenVINO IRs used for the reported numbers
  (`ov-tiny-qwen3next-hybrid`, the MoE-enabled variant, kept alongside for the record — GPU-
  incompatible, CPU-only calibration data)

**What was NOT tested / explicit gaps:** the actual production-scale 27B/35B-A3B models from the
original report (these are ~21-22M param synthetic, matched-architecture but not matched-scale);
the OVMS server layer itself (GenAI-level only, per mzegla's stated preference); `--kv_cache_
precision u8`; `enable_prefix_caching=true` with a more diverse prompt pool (turned off after it
suppressed pressure against a small repeated-prompt pool); the disconnect/cancellation path
(withdrawn as the trigger by the original reporter, intentionally not exercised); any hardware
beyond this one Arc 140V (Xe2) iGPU; more than N=8 trials per configuration; the exact root cause
of either the leak or the reported assertion (out of scope — reproduction and comparison were
asked for, not a fix). Checked `openvino.genai` `master` (`7c6f0fa61e`, 2026-08-19) for commits
touching `block_manager.hpp` since the `releases/2026/2` branch point — two found (`#3938`,
`#3854`), neither related by title/path; titles only, not full diffs, so not a substitute for the
maintainers' own check.

**Vikunja:** new task #1446 (project 11, index #9) founded at the start of this work — no prior
ticket existed for this engagement. Labeled Active, Testing, Gate:Pending-Human.

**Next:** Blair reviews the draft comment and raw logs; if approved, post to `model_server#4428`
addressed to mzegla (apaniukov/popovaan already CC'd on-thread by mzegla). No GitHub posts or
pushes were made this session.

**Update (same session) — team-lead independently re-verified the correction against the raw
comment bodies (not the summary above) and confirmed it, plus surfaced three things folded into
the draft before it goes to Blair:**
1. lusoris's exact confirmed numbers (`--cache_size 4`, ~3.6GB free after weights, ~151MB x 16
   slots ≈ 2.4GB linear-attention pre-commit, ~33KiB/token KV across 16 full-attention layers,
   two ~20k-token sequences filling the cache) — added to the draft so it's explicit the
   reproducer targets the same *mechanism*, even though it can't match the same *scale* (a
   ~21-22M param synthetic model vs. 27-35B).
2. **Do not imply a single unified root cause.** lusoris's 2026-08-04 comment already showed
   disconnects aren't required; a 2026-08-05 cross-reference to a llama-swap maintainer's theory
   (disconnect-triggered cancellation racing the executor) was posted the day *after* that, so it
   may describe a distinct, still-open, still-theorized path rather than the confirmed one. The
   draft's opening was rewritten to state plainly that this work is scoped to the cache-exhaustion
   path only and takes no position on the disconnect-cancellation theory either way.
3. **Etiquette.** lusoris explicitly offered (2026-08-18) to build their own OVMS-level
   reproducer on B60/B580 given a target shape — that hasn't happened yet on-thread. The draft now
   opens by crediting lusoris by name for the diagnostic math, frames this as a complementary
   GenAI-level angle (not a duplicate or a "got there first"), and offers to hand off scripts
   rather than presenting the work as done unilaterally.

Draft comment file unchanged in location (`draft_comment_4428.md`), revised in place. Still not
posted.

**Update (2026-08-19/20) — team-lead independently re-verified the entire draft against the raw
artifacts, not the drafting agent's summary, before it went to Blair.** Cross-checked all 48 raw
trial log lines against the draft's results table (exact match, no discrepancies); re-read the
actual source at the pinned commit to confirm the `block_manager.hpp:633` /
`free_group_partially()` / `scheduler.hpp` preemption-path trace; went one step past the drafting
agent's own check on PRs `#3938`/`#3854` by reading their actual diffs, not just titles, and
confirmed neither touches the relevant code; confirmed the git-stash hygiene state, confirmed zero
comments existed yet from Blair's account, and confirmed the `build_models.py` model construction
genuinely uses the real `transformers.Qwen3NextConfig`/`Qwen3Config` classes rather than a
fabricated architecture. Zero defects found in two independent review passes (before and after the
etiquette revision above).

Per Blair's request, also: (1) tightened one remaining hedge in the draft — "I only checked
titles/paths, not full diffs" on `#3938`/`#3854` was replaced with the actual, stronger claim now
verified via the diffs; (2) quantitatively audited the draft against researched AI-writing tells
(word counts, via `WebSearch` — em-dash frequency, "moreover/furthermore" usage, buzzword list,
"in conclusion"-style phrasing) and found the sentence-interrupting `" - "` construction
(functionally the same rhetorical role as an em-dash) at 23 instances in 1,537 words, far above
the researched target of effectively zero; rewrote the draft to reduce this to 1 instance in 1,485
words while diffing every technical figure against the prior version to confirm zero facts were
altered in the process.

**Posted.** Blair reviewed the tightened draft and gave explicit go-ahead 2026-08-20. Posted via
`gh api -X POST repos/openvinotoolkit/model_server/issues/4428/comments` with a payload built via
`[System.IO.File]::WriteAllText` in PowerShell (avoiding both the `-f body=@file` substitution
failure from the `openvino.genai#4139` incident and a `Get-Content`/`ConvertTo-Json` ETS-property
corruption bug caught mid-session while preparing an unrelated Vikunja comment). Live at
https://github.com/openvinotoolkit/model_server/issues/4428#issuecomment-5357627024
(`2026-08-20T14:55:56Z`). Verified byte-for-byte against the live API response immediately after
posting — the only diff was a trailing blank line at the very end of the comment (cosmetic
rendering artifact, not a content difference).

**Vikunja task #1446 updated:** `Gate:Pending-Human` label swapped for `Gate:Approved` via the
dedicated label endpoints (not a full-task PATCH); a status comment with the live link was added;
`due_date` set to `2026-09-03` (a ~2-week check-back, matching the pattern used on task #923) via
a read-full-record-then-patch-one-field flow, backed up first and verified afterward that title
(3815-char description, unchanged), priority, and labels all survived intact — no repeat of the
earlier full-record-wipe incident.

**Scope decision explained to Blair, worth recording:** the reproducer deliberately used tiny
(~21-22M param), randomly-initialized, architecture-matched synthetic models instead of the
production-scale 27B/35B-A3B models from the original report. This was a considered engineering
trade-off, not an oversight, and it's stated as an explicit gap in the posted comment itself. Two
independent reasons: (1) hardware fit — the original report's crashing model's language-model
weights alone are ~13.9GB (per `model_server#4461`'s reproducer, a closely related model in the
same family), and the reporters who did use full-scale models ran on discrete cards (Arc A380, Arc
Pro B60, B60/B580) with dedicated VRAM in that range or higher; Blair's Arc 140V is an integrated
GPU sharing ordinary system memory, and loading a model that size would compete with everything
else running on the machine and risks introducing an unrelated OOM/driver failure mode that would
have confounded the specific cache-exhaustion signal being isolated; (2) trial volume — the whole
point of the comparison was running enough trials (48, N=8 per config) to get a clean statistical
split between the two architectures, and each trial's wall-clock cost scales with model size and
step latency; a 27-35B model would have made anything near that trial count impractical within a
single session. Not yet assessed: whether a real (not tiny/random-init) but still session-tractable
model exists in the Qwen3-Next family — worth a feasibility check if a next pass with real
pretrained weights is wanted.

**Next:** awaiting mzegla/apaniukov/lusoris response on the live comment. No further action queued
unless/until the thread moves.

---

### 2026-08-20 — this workspace now has a public counterpart

*Plain summary: Blair asked whether to publish this folder as a portfolio repo. Surveyed what was
actually in it before proposing anything — found the meta-repo itself was small and mostly clean,
but `CLAUDE.md`, the `upstream-contributor` agent file, and 23 scattered lines across 18 build/log
files all referenced or exposed details of a separate, private project by name. Built the
public repo as a completely fresh export rather than reusing this repo's existing git history, so
none of that could leak in even as a past commit.*

Blair's explicit instruction: exclude `CLAUDE.md` entirely ("that is definitely kind of
personal"). Found `.claude/agents/upstream-contributor.md` carries the identical framing
verbatim and excluded it too by default, flagged rather than silently decided. Also found 23
occurrences across 18 files (`repro266/*.cmd`, `_verify_npu_guard/*.bat`, watchdog scripts,
`docs/CONTRIBUTIONS_LOG.md` itself) that named the private project or revealed local paths into
it (a specific quantized model path, a separate OpenVINO checkout location). Presented this to
Blair rather than deciding unilaterally, given "whether something goes public" is explicitly his
call; he chose to redact rather than exclude those files, preserving the real reproduction
evidence.

**Redaction approach:** literal string replacement (PowerShell `.Replace()`, not regex, to avoid
any escaping mishap on Windows paths) — `private project's openvino\... paths repointed to this repo's own
`oss\openvino\...` convention (both anonymizing and staying internally consistent/correct for a
reader trying to reproduce), `private project's model paths genericized, stray Claude-session
scratchpad temp paths stripped, one prose line in the log itself genericized. Verified zero
residual private-project-name matches (case-insensitive) across the full export afterward, plus a separate
scan for email addresses and secret-shaped strings before anything was pushed — clean (the only
emails present were Blair's own, already-public commit-authorship address, a third-party mailing
list address in a build log, and the standard Claude Code co-author address).

**Published:** https://github.com/blairducrayoppat/openvino-contributions (public, 88 files).
Built as a fresh `git init` in a separate directory (`oss-public/`, not tracked by this repo),
populated only from this repo's tracked file list minus `CLAUDE.md`/`.claude/`, so the public
repo's history has exactly one commit and never contained the excluded files, not even
transiently. Verified against the live GitHub tree API after push, not just local `git status`,
that neither `CLAUDE.md` nor `.claude/` appear anywhere in the pushed tree.

**Not yet done:** no decision made on whether future contributions from this workspace should be
mirrored to the public repo going forward, or whether this was a one-time snapshot. That's a
process question for Blair, not resolved here.

---

### 2026-08-20 (later) — built a repeatable public-repo sync, answered "should it be manual or automatic"

*Plain summary: Blair wants to manually re-run the screen-and-mirror process from time to time,
not have it happen automatically. Built that as a Claude Code skill wrapping a PowerShell script
-- the script handles what's safely mechanical (known exclusions, known redactions, pattern-based
secret/email scanning), the skill instructs whoever runs it to actually read anything new rather
than trust the pattern scan alone. The very first test run validated the design by immediately
finding a real, previously-unknown leak.*

**Built:** `scripts/sync_public_repo.ps1` (re-derives the curated file list from `git ls-files` in
`oss/` each run, excluding `CLAUDE.md`/`.claude/` and the two publicly-owned files
(`README.md`/`.gitignore`); applies a maintained table of known literal-string redactions;
diffs against the existing public export to report additions/removals; scans for secret-shaped
strings, emails, and residual private-project-name mentions; stages but does not commit or push without
`-Commit`/`-Push`) and `.claude/skills/publish-public-repo/SKILL.md` (the review process wrapped
around it — read every new file yourself, review every scan flag, get Blair's explicit go-ahead
on that run's specific diff before pushing, every time, not just once).

**First live test found a real problem, which is the point.** Ran the script against the current
workspace state (nothing structurally new since the manual sync above — 0 new/removed files) and
it immediately flagged that this log's own OWN new entries (the two directly above, describing
the manual redaction work) named the private project by name in explanatory prose, and that a
different entry further up named the actual internal environment-variable names
(token, URL, etc.) used for the project-management tool — infrastructure
detail, not a credential value, but not public-repo material either. Neither had existed at the
time of the original manual sync; both were introduced by this session's own subsequent writing.
Added both as new entries to the script's redaction table (with Blair's already-established
preference: redact, don't exclude) rather than editing the private source text, which stays
exactly as originally written.

**Debugging the redaction mechanism itself, worth recording honestly rather than glossing over:**
three real bugs surfaced getting the new redaction entries to actually match, none in the original
23:
1. PowerShell hashtable keys are case-insensitive by default -- the original `[ordered]@{}`
   literal silently collided two case-variant private-name find-strings as the same key and refused to
   parse. Fixed by switching the whole redaction table to an array of `(Find, Replace)` pairs
   instead of a dictionary.
2. A find-string containing literal backticks, written inside PowerShell double quotes, got
   mangled (backtick is PowerShell's escape character in double-quoted strings). Fixed by
   single-quoting every literal string in the table from that point on.
3. A multi-line find-string (matching text that wraps across two lines in the source) failed to
   match even after fixing the above, for a reason not fully isolated (line-ending and encoding
   checks on both files came back matching). Rather than keep debugging a fragile mechanism,
   split it into two shorter, single-line matches -- simpler, and it worked immediately.
Each fix was verified by re-running the script's scan mode and confirming the specific flag
cleared, not assumed from the code change alone.

**Verified after push, not just local `git status`:** fetched the live tree via
`repos/.../git/trees/main?recursive=1` (empty for any `claude`/`CLAUDE` path) and the live
`docs/CONTRIBUTIONS_LOG.md` content directly from the GitHub API (empty for the private-project name,
or the credential variable names) after the sync pushed. Commit `78045b9` on
`blairducrayoppat/openvino-contributions`.

**One flag deliberately left unresolved, and why that's correct, not an oversight:** the scan
still flags the word "secret" in this log's own line describing the scan methodology ("scanned
for email addresses and secret-shaped strings") -- a false positive by construction, since it's
describing the check itself, not exposing one. Left as-is rather than chased into silence, and
noted here so the next person running this skill understands that a nonzero flag count is
expected and does not by itself mean something is wrong.

**Answers the standing "not yet done" question above:** manual, on-demand, per Blair's explicit
instruction -- not continuous or automatic. `/publish-public-repo` (the skill) is how future
syncs happen.

---

### 2026-08-20 (evening) — `openvino.genai#4139` moved: ReasoningConfig refactor landed, our offer accepted, review formally requested; full triage + two drafts, nothing posted

*Plain summary: the PR author did the maintainer-requested API redesign, accepted Blair's
standing offer to implement the base-class swap, asked Blair to look at two more things (a
sampling bug and the C++ auto-detect), and formally requested Blair's review. We pulled full
live state, reviewed the new commit at the code level, root-caused the sampling bug deeper than
the author's own diagnosis, and drafted both a reply comment and a formal review. Everything is
drafted only; Blair decides what gets posted.*

**What changed on the PR since the 2026-08-19 check (all pulled via `gh api` / GraphQL, never
WebFetch):**
1. Commit `316f605505ce` pushed 2026-08-21T01:35:53Z (UTC) — the `ReasoningConfig` refactor
   answering apaniukov's request #2. SHA verified live as the PR head before any use (the
   email notification's `316f6055` matches). 11 files, +168/−104.
2. PlanteAmigor comment (id 5364197632): refactor done and locally validated on Qwen3/3.5/3.6;
   raises a pre-existing multinomial-sampling force-close bug for discussion (proposes a
   sampler-side fix); says C++ auto-detect attempts "didn't seem to work", asks Blair to look;
   accepts Blair's items-3/4 offer ("your help would be great").
3. Formal review request to `blairducrayoppat` (verified in `requested_reviewers`).
4. New Copilot review (2026-08-21T01:45:58Z) with 3 inline comments — all three checked against
   the actual diff and confirmed genuine (below), unusual for Copilot noise.
5. `mergeable_state` now `dirty`. Trial merge run locally (`git merge-tree`, no working-tree
   changes): conflicts confined to the two auto-generated `.pyi` stubs.
6. Real CI still gated: only the PR-labeler has ever run, on this head too.
7. apaniukov's 4 threads: #2 outdated-but-unresolved (addressed by the refactor), #1 open,
   #3/#4 open and NOT outdated — the base-class swap is still ours to do; the transform class
   at head is still `ILogitTransformer`.

**How the code review was grounded:** fetched the PR branch into
`openvino.genai-pr-worktree/` as local branch `pr4139-review` plus a `master` snapshot ref —
fetch only, nothing checked out, no working-tree or branch state touched (tree verified clean
before and its checked-out branch unchanged). All reading via `git show`/`git diff` at
`316f6055`, cross-diffed against the PR merge-base `1f06830c` to separate PR-introduced changes
from upstream.

**Review findings on `316f6055` (code-level only — NOT built, NOT run):**
- Sound: `ReasoningConfig` mirrors the `StructuredOutputConfig` pattern exactly as apaniukov
  asked (AnyMap ctor, `update_config`, `optional<>` member, kwargs binding, `py_utils` cast,
  stubs/exports); `budget=0` correctly replaces `enable_thinking=false`; Blair's 11 C++ tests
  are untouched and stay source-compatible (constructor and `accept_token` signatures unchanged
  at head — the risk flagged in the 2026-08-19 addendum did not materialize).
- **Blocker found: the refactor accidentally deleted the pre-existing
  `stop_token_ids`-must-contain-`eos_token_id` assert from `GenerationConfig::validate()`**
  (verified absent from the whole file at head via grep; present at the parent commit; not
  moved anywhere). Two existing upstream test cases (`test_invalid_fields_assinment_rises`,
  `eos_token_id=1` variants) cover it and will fail once CI runs.
- Confirmed Copilot finding: the PR's own 11 Python test cases in
  `test_generation_config.py` still use the removed flat kwargs — they no longer test the new
  API and will fail.
- Confirmed + severity-verified Copilot finding: the new kwargs overload in
  `py_vlm_pipeline.cpp` unconditionally inserts a default-constructed `GenerationConfig` into
  the property map; `resolve_generation_config()` (`pipeline_base.hpp`) only falls back to the
  pipeline's stored config when that key is absent (`value_or`), so every kwargs-path VLM
  `generate()` call without an explicit config now loses the model's loaded
  `generation_config.json`. PR-introduced (absent at merge-base).
- Minor: a comment block in `logit_processor.hpp` came back in Chinese (an earlier commit on
  this same branch translated those); the rewritten auto-detect comments lost their
  `<think>`/`</think>` literals in 3 places; stray trailing whitespace on one comment line.

**Multinomial force-close bug — diagnosis confirmed and refined (code-level analysis, not
runtime-reproduced):** the author's read (end_token_id missing from the top-k/top-p-restricted
`m_vector`) is right but incomplete. `_multinomial_sample` draws from `m_vector` once
initialized, and everywhere except the fused `defer_expf` path the values are already
probabilities by the time `ThinkingBudgetTransform` (registered last) masks them, so writing
`-inf` (a logit-domain sentinel) poisons the weight sums and trips the sampler's defensive
uniform fallback even when `end_token_id` survives filtering; temperature-only sampling hits
the same failure through `m_data`. The uniform fallback silently samples a random candidate —
matching the author's observed "garbage output" and "doesn't reliably force" symptoms exactly.
Position taken in the draft: fix inside the transform (when FORCING on the multinomial path,
replace the candidate set with the single entry `{1.0f, end_token_id}`; keep `-inf` `m_data`
masking for greedy/beam; one constructor flag from `LogitProcessor` tells the transform which
path it is on) rather than the author's sampler-side detect-and-emit, which would couple the
sampler to transform internals and need per-call-site handling plus manual logprob bookkeeping.
Final shape explicitly deferred to apaniukov in the draft.

**Item #1 (C++ auto-detect) hypothesis:** the Python auto-detect already calls
`pipe.get_tokenizer().encode(...)` — the same C++ `ov::genai::Tokenizer` — so a port is
behavior-identical in principle; the likely failure in their attempt is modifying a config copy
that never reaches `LogitProcessor` (facade vs. stateful/CB impl config resolution, chat mode's
own config). Draft asks for their attempt's diff and offers to take the item, with a plan (one
shared helper at each pipeline's config-resolution point, then delete the three Python-side
copies — which also removes the VLM clobber site).

**Items #3/#4 plan (committed in draft):** swap base to `IStatefulLogitTransformer`;
`accept_tokens()` loops the existing single-token logic (keeps Blair's tests source-compatible,
handles spec-decode multi-token acceptance); register via `m_stateful_logit_transformers` like
structured output; delete the dedicated `m_thinking_budget` member + special-case call; extend
`logit_filtering.cpp` with multi-token-acceptance coverage. Delivery via Blair's fork branch →
author merges (same route as `f90cc875`). Known limitation noted: `LogitProcessor` has no
rollback notification for stateful transformers under speculative decoding — pre-existing,
affects grammar too, out of scope.

**Drafts (NOT posted — no external writes of any kind this session):**
- `C:\Users\mrbla\oss\scratch_pr4139\draft_reply_comment.md` — reply to PlanteAmigor.
- `C:\Users\mrbla\oss\scratch_pr4139\draft_review.md` — formal review; recommendation is to
  submit as COMMENT (not approve — unbuilt; not request-changes — heavier than doctrine wants
  against a student author), with 4 inline comments anchored to `316f6055` line numbers.
  Anchors and the head SHA must be re-verified at post time.
Both drafts carry the AI-disclosure line and passed the dash-frequency audit (0 interrupting
dashes in the reply draft).

**What was NOT verified:** nothing was built or executed — the eos-assert deletion, the VLM
clobber, the test breakage, and the entire multinomial mechanism are code-reading conclusions
(each cross-checked against the actual sources at exact commits, but not runtime-reproduced);
CI has never run on the PR to confirm the test failures; the #3/#4 implementation is not
started. Build + `logit_filtering` run on this machine is the named next step after Blair
approves the posts.

**Vikunja #923:** comment id 3223 added; labels `Active` + `Gate:Pending-Human` attached via
the dedicated label endpoints (no task PATCH issued — title/due/priority/description verified
intact afterward). Due date left at 2026-08-25 as backstop.

**Next:** Blair reviews both drafts; if approved, post comment then submit review (re-verifying
head SHA first), then start the #3/#4 branch and the build-verify pass on Arc 140V.

**Update (same session) — Qwen3.8 research merged into both drafts.** A parallel researcher
(team-lead relay) supplied findings on the just-released Qwen3.8-27B and Qwen's official budget
documentation. Every load-bearing claim was re-verified here against the researcher's raw
evidence files before entering the drafts (shipped `generation_config.json` for Qwen3.8/3.6:
`do_sample=true, temperature=1.0, top_k=20, top_p=0.95`; think-token ids moved to
248068/248069 with `special:false`; chat template pre-fills `<think>\n` in the generation
prompt; the exact early-stop sentence in QwenLM/Qwen3's official `thinking_budget.md` recipe;
Qwen Cloud's `thinking_budget` semantics line). Draft changes: (1) multinomial section now
cites the shipped defaults, making the broken path demonstrably the out-of-box path for the
target models; (2) added the sequence-forcing design option (force Qwen's official early-stop
sentence token-by-token, which matches first-party semantics and fixes the sampling bug by
construction), framed as apaniukov's call alongside the simple single-token rewrite; (3) item
1 strengthened with the token-id drift (per-generation trap for hardcoded ids) and the fact
that Qwen3.8-27B is a VLM, making the VLM auto-detect path first-class; (4) review body now
affirms the constructor prompt-scan as load-bearing for 3.5/3.6/3.8 templates and suggests a
PR title/description refresh. Two researcher claims were corrected before use: the
"range 1-32768, default 4000" figures are Qwen Cloud console-panel-only (correction relayed by
the researcher themselves and honored), and "zero `enable_thinking` hits remain at head" is
wrong as stated (the chat-template kwarg and a test comment remain; only the GenerationConfig
field is gone) — the review wording was made precise. Disclosure lines extended to cover the
model research; still static-analysis-only, still nothing posted. The researcher's raw
evidence files (Hub configs/templates/tokenizer configs for Qwen3.8/3.6, the byte-verified
QwenLM/Qwen3 `thinking_budget.md`, and the extracted Qwen Cloud thinking page) were copied out
of the ephemeral session scratchpad into `C:\Users\mrbla\oss\scratch_pr4139\evidence\` so the
verification trail survives the session. The review draft's inline comment 3 also gained the
tie-in that Qwen3.8-27B, being a VLM, lands on exactly the kwargs overload with the
config-clobber regression.

**Update (same session, later) — PR head moved to `9391584`; drafts re-anchored; our VLM
clobber finding was fixed upstream before we could post it.** Verified live via `gh`: new head
`93915841747b2ccd9070a4a92da86b61d4b66cba` (2026-08-21T02:17:52Z), one new commit touching only
`py_vlm_pipeline.cpp` (+3/−1): PlanteAmigor initialized `gen_cfg` from
`pipe.get_generation_config()` instead of default-constructing it, crediting the Copilot
comment — the exact regression our draft review's inline 3 flagged, fixed ~22 minutes after
Copilot raised it. Re-verified at the new head rather than assuming: the deleted eos assert is
still absent (grep count 0), the trial merge against master still conflicts only on the two
`.pyi` stubs, and the diff scope confirms every other reviewed path is byte-identical.
Draft changes: all SHA citations re-anchored to `9391584` (zero `316f6055` references remain);
the reply's must-fix arithmetic is now two items plus credit for the third; review inline 3
rewritten to cover the fix's two residues — a stale "default-constructed" comment (line 401,
cosmetic) and a real wrinkle at line 403 where the `!has_value()` guard now makes a per-call
`reasoning_config=` kwarg bypass auto-detect when the pipeline already carries one (traced
fully: the kwarg still wins downstream via `update_generation_config`, but with token ids
unfilled the transform is never created, so the budget silently goes unenforced — this
CORRECTS the researcher relay's claim that the kwarg is "silently swallowed"; it is applied,
un-auto-detected). Copilot also posted two new inline comments on `logit_processor.hpp` with
the same review; both were verified against the sampler at the new head and both are REAL and
pre-existing: (a) one `LogitProcessor` per request (`RequestSamplerContext`,
`sampler.hpp:129`) means all forked sequences under `num_return_sequences > 1` advance the
same thinking state machine via `register_new_token` (`sampler.cpp:1561→1114`); (b) the
spec-decode rollback (`align_all_sequence_len`, `sampler.cpp:1170-1185`) removes tokens and
occurrence counts but never rewinds the machine. The reply's items 3/4 section now explicitly
extends scope to both (per-sequence state or a `validate()` guard; committed-tokens-only
updates or snapshot/restore), turning the bot comments into evidence for the committed plan.
Still drafts only; still nothing posted; still static analysis with no build.

**Update (same session, final pass) — structured-output collision added to the reply.** From
the researcher's Qwen Cloud function-calling page (byte-verified; `qwencloud_funcall.txt` and
`qwencloud_streaming.txt` copied into `scratch_pr4139\evidence\`, now 11 files): Qwen's own API
restricts `tool_choice` to auto/none under thinking mode ("To force a specific tool, disable
thinking mode first" — line 353 of the extracted page). Self-verified at head `9391584` before
drafting: the grammar transformer registers at `logit_processor.hpp:59-63`, the thinking
transform last at 119-135, and `validate()` says nothing about combining
`structured_output_config` with `reasoning_config` — so in FORCING the two masks can starve
each other (grammar excludes `</think>` → all candidates `-inf`, same failure class as top_k;
conversely a forced `</think>` can violate the grammar). Reply gained one paragraph proposing a
`validate()`-level rejection of the combination as cheap honest scope, citing the vendor
precedent; to keep length flat, the prompt-scan template note was trimmed from the reply (the
review body retains it in full). Researcher's two discretionary items initially NOT added:
the friendlier validate() error message when auto-detect silently fails (better delivered as a
small code improvement in the items 3/4 branch than as comment noise) and the
starts-inside-thinking parser question (whether genai wires such a parser for Qwen is
unverified and was not quickly verifiable; dropped rather than posted as a hedge). Reply now
1558 words, 0 dash interrupters, 0 stale SHA references. On team-lead's follow-up nudge the
error-message item was added after all, as one sentence inside review inline 3 where it
dovetails with the budget-silently-unenforced residue (the validate() message text quoted
there was verified from the head sources); the parser question stays dropped.

**Check 2026-08-21T02:36Z (Blair forwarded a new notification email):** pulled full live
state again (PR meta, issue/review/commit comments, timeline events, comment edits, CI runs) —
zero activity since 02:17:52Z. The email is the push notification for `9391584` (PlanteAmigor's
fix, already triaged above) plus the Copilot re-review; the actor is the PR author, not
maintainer apaniukov, who has been silent since 2026-08-11. Nothing new to respond to; drafts
unchanged, still pending team-lead review pass then Blair's posting decision.

---

### 2026-08-20/21 (overnight) — `openvino.genai#4139` hardware verification pass at head `9391584`: bug reproduced, fix verified, all draft predictions upgraded to observed facts

*Plain summary: built the PR from source on Blair's Lunar Lake machine and ran a scoped test
pass. Every code-level prediction in the drafts survived contact with reality: the deleted
assert really no longer fires (observed test failures), the stale Python tests really fail
(18/114), the multinomial force-close bug really happens on the shipped-defaults settings
(0/8 runs ever closed the think block, across CPU and GPU), and the author's hour-old VLM fix
really works (verified on a real VLM). One refinement: under top_k/top_p defaults the failure
looks like fluent text that silently ignores the budget, not overt garbage.*

**Independent review outcome (same session, before the hardware pass):** the team-lead's
`upstream-review` pass verified ~40 load-bearing claims and required three fixes, all applied:
(1) the auto-detect-bypass consequence corrected from "budget silently unenforced" to a loud
`validate()` failure (the reviewer was right: `setup_generation_config` at
`visual_language/pipeline.cpp:708` always validates — self-verified before applying, and then
CONFIRMED EMPIRICALLY in test T3 below, closing the loop on a claim that had now been corrected
twice); (2) inline 4 reworded — `logit_processor.hpp` never had Chinese comments before
(`87acf7b` translated only the two Python binding files; self-verified via `--stat`); (3)
"untouched" tightened to "functionally untouched". The queued #4082 tie-in edit was applied in
the same pass. Commitment-envelope language HELD unchanged pending Blair's decision (team-lead
put it to him).

**Build (all timings wall-clock from the status marker file):** `openvino.genai` at PR head
`9391584`, checked out in `openvino.genai-pr-worktree/` (branch `pr4139-review`; original
branch `fix/xgrammar-stop-token-spec-decode` @ `4c797722` recorded for restoration — left
checked out on `pr4139-review` deliberately since the items-3/4 branch builds on it; tree
verified clean). Tokenizers submodule initialized at `6caf6c18`. MSVC 19.44.35222 (VS 2022
BuildTools), Ninja, Release, `ENABLE_PYTHON=ON ENABLE_TESTS=ON`, against OpenVINO nightly
wheel `2026.4.0.dev20260820` in a fresh venv (`pr4139-venv/`; the local March `openvino/`
build is 2026.2-era and cannot satisfy head's `find_package(OpenVINO 2026.4.0)`). Configure
2m27s, build 7m24s. Machine idle-checked before starting (no competing builds).

**C++ unit tests:** full `tests_continuous_batching` suite: **569 ran, 567 passed** in 12.8s;
the 2 failures are gtest's complaints about intentionally-uninstantiated real-model
parameterized suites (need model env vars; pre-existing, unrelated to the PR). Filtered:
**14/14 `ThinkingBudgetTransformTest`** (Blair's 11 + PlanteAmigor's 3) and 20/20 other
logit-transform tests. The drafts' "existing suite stays source-compatible" claim is now an
observed fact.

**Python config tests (pytest `--noconftest`, config-level only — conftest needs
transformers/optimum which the tests themselves don't):** `test_generation_config.py` at head:
**18 failed / 96 passed**, exactly the predicted failures and no others — 6 stale valid-config
cases (`AttributeError: 'GenerationConfig' object has no attribute 'enable_thinking'` in
`verify_set_values`), 5 stale invalid-config cases (DID NOT RAISE), 7
`test_invalid_fields_assinment_rises` cases including **both `eos_token_id` cases failing DID
NOT RAISE — direct runtime proof the deleted assert no longer fires** (review inline 1).

**Multinomial force-close repro (LLMPipeline, Qwen3-0.6B exported via optimum-intel 2.1.0,
int8_asym weights, fixed prompt, `budget=32`, `max_new_tokens=220`):**
- Greedy: clean force-close at exactly the budget point (`</think>` at char 134,
  mid-sentence, coherent answer follows). N=2 CPU (byte-identical outputs), N=1 GPU
  (Arc 140V, driver 32.0.101.8826) — same close position.
- Multinomial, shipped-defaults shape (`do_sample=true, temperature=1.0, top_k=20,
  top_p=0.95`, seeds 1000+): **0/5 CPU and 0/3 GPU runs ever emitted `</think>`** —
  device-independent, as expected for sampler logic.
- Mechanism instrumented (temporary local `fprintf` in the two sampler fallback branches,
  reverted immediately after — `git status` clean, then clean rebuild): one 220-token run
  showed the **normalized-path uniform fallback engaging on all 187 post-budget steps**,
  candidate-set size K=1 on 76 of them, K≤10 on nearly all. Refinement over the author's
  "garbage output" description: under these defaults the fallback draws uniformly from a tiny
  set of already-plausible top-p candidates, so text stays locally fluent while the budget is
  silently ignored; overt garbage is expected on the full-vocab paths (temperature-only /
  logprobs). Exported Qwen3-0.6B itself ships `do_sample=true, top_k=20, top_p=0.95` — the
  bug is its out-of-box path too.

**VLM pass (scope extension using Blair's local models, no new downloads):**
- First candidate (`qwen3.5-0.8b-vlm` export, `model_type qwen3_5` — same family as
  Qwen3.8-27B) fails to load on master genai: language model IR lacks the `position_ids`
  input the 2026.4-dev pipeline expects (2026.2-era export; enablement drift, out of PR
  scope, recorded here only). Its ov tokenizer does encode `<think>`/`</think>` as single
  tokens **248068/248069** — the token-drift data point now runtime-verified.
- Used instead: **Qwen3-VL-8B-Instruct int4** (5.1GB, `model_type qwen3_vl`, think tokens
  151667/151668 single-token through its ov tokenizer). Results, CPU:
  T1 — **the `9391584` fix works**: kwargs-only `generate()` honors stored
  `max_new_tokens=7` exactly (7-token output). T2 — per-call kwarg still overrides stored
  config (output ran past the stored 7-token cap to a natural EOS at 12). T3 — **the
  INLINE-3 residue reproduced exactly as the corrected drafts predict**: per-call
  `reasoning_config=ReasoningConfig(budget=8)` on a pipeline already carrying one raises
  `RuntimeError ... "reasoning_config.start_token_id and end_token_id must both be set"`
  (from `generation_config.cpp:320`), with no mention of auto-detect. T4 — `budget=0`
  forcing works on the VLM path (`</think>` emitted as the FIRST token, sane answer
  follows); mid-generation budget forcing on the VLM was NOT conclusively exercised (with
  `budget=12` the Instruct-trained model answered directly with no think block — consistent
  with the chat template inserting a closed think block, putting the transform in DONE;
  labeled inconclusive-infrastructure, not a transform defect).

**Drafts updated in place** (the same single post-review revision): runtime results woven into
the multinomial section, the fix acknowledgment, the residue sentence, items 3/4 baseline, and
both disclosure/methodology blocks; review inlines 1/2/3 upgraded from predictions to observed
facts. Audits still clean (0 dash interrupters; no stale "will fail"/"not runtime-tested"
phrasing). Raw run logs preserved in `scratch_pr4139/run_*.txt`; scripts
`repro_multinomial.py`, `vlm_tests.py`, `vlm_t4*.py` alongside.

**Still not verified, named:** Qwen3.8-27B OpenVINO conversion; mid-generation VLM budget
forcing on a thinking-trained VLM; the early-stop-sentence variant; XGrammar desync at
runtime; N beyond the stated counts; NPU untested (not applicable to this PR's paths).

**Update (2026-08-20 ~23:20-00:15, same night) — Blair's GO: items 3/4 plus the multinomial
fix implemented on a local branch, all green, nothing pushed.** Blair moved the timeline from
"within a few days" to tonight. Branch `feat/thinking-suppression` created off head `9391584`
in the PR worktree (local only; push awaits his explicit go). Three commits, each labeled
take-or-leave where it exceeds the accepted offer:
1. `78f53499` — the maintainer-requested items 3/4: `IStatefulLogitTransformer` base swap,
   `accept_tokens()` looping the single-token machine, registration via
   `m_stateful_logit_transformers` (structured-output pattern), dedicated member and
   special-case call deleted. +4 tests. Suite: 573 ran / 571 passed, 18/18 ThinkingBudget.
2. `8760e383` — the proposed multinomial fix as its own commit: `multinomial_path` flag
   (default false, all existing callers unchanged), FORCING on that path replaces the
   candidate set with `{1.0f, end_token_id}`. +4 tests. Suite: 577 ran / 575 passed.
   **Smoke-verified end to end: seed 1000, which never closed at head, closes at char 134 on
   the branch — the exact position of the greedy baseline's forced close.** Formal N=5 CPU +
   N=3 GPU before/after queued behind the battery (Bucket A).
3. `adbe4bea` — validate() guard rejecting `budget >= 0` with `num_return_sequences > 1`
   (the Copilot parallel-sampling finding; per-sequence state is the maintainer's
   architectural call). Runtime-verified in all three directions (rejects n=2, accepts n=1,
   accepts budget=-1 with n=2). No C++ test home exists for validate(); the Python case
   belongs in the `test_generation_config.py` rewrite the review requests, noted in the
   commit message. The ROLLBACK lifecycle item was deliberately NOT implemented: both
   candidate shapes change the Sampler↔LogitProcessor contract, the exact design choice the
   drafts defer to apaniukov.
**Battery coexistence:** `M2-Battery-Nightly` confirmed Running since 23:00; all
builds/tests since the constraint arrived ran pinned to cores 3-7 at BelowNormal, `-j 3`
(commit-2 build+suite ~15+ min vs ~4 min unloaded — expected contention, not thrashing); no
battery paths touched; no GPU runs since the constraint. Honesty note: the earlier GPU repro
and VLM runs (~23:05-23:20) overlapped the battery's first minutes before the constraint
arrived; their claims are behavioral (deterministic seeded outputs, exception texts), not
timing, so no result is contaminated, and no wall-clock numbers were cited from them.
**Next:** on the team-lead's BATTERY ENDED signal (~03:45): Bucket A (branch suite + formal
before/after repro at tonight's exact methodology), Bucket B (fresh qwen3.5-0.8b VLM
re-export to a NEW dir, old export preserved as drift evidence; close the T4 inconclusive),
Bucket C optional. Then the final draft revision folds in the before/after numbers and the
"branch ready" timeline wording, pending Blair's envelope verdict and posting go.

**Update (2026-08-21 ~02:50-03:40, appended out of place — see the T4 entry below for the
00:30 diagnosis that precedes this) — post-battery phases 1-3: XGrammar collision demonstrated,
before/after formalized, canary passed, thinking-VLM findings closed, 27B conversion launched.**
Battery ended 02:50 (team-lead signal); coexistence constraints lifted. All run logs saved to
`scratch_pr4139/` per the adopted rule.
- **Phase 1 (head build):** XGrammar×ThinkingBudget collision DEMONSTRATED, deterministic
  across repeats (`run_cpu_xgrammar_desync_head.txt`): grammar alone → valid `{"answer": 8}`;
  budget=8 alone → clean forced close then a JSON answer; both together → `{"answer": 8` then
  41 repeated `!` tokens (token id 0 — the all-masked-argmax signature predicted from code),
  `</think>` never emitted, JSON never closed. Additional GPU N: head multinomial now **0/8 on
  GPU** (was 0/3), head totals 0/13 across devices.
- **Phase 2 (branch build):** full suite 577 ran / 575 passed; **before/after centerpiece:
  head 0/5 CPU + 0/8 GPU closes → branch 5/5 CPU + 3/3 GPU closes at the budget point (chars
  125-134), same seeds, greedy unchanged**; validate() guard re-confirmed on the final branch
  build. Logs: `run_cpu_multinomial_b32_branch.txt`, `run_gpu_multinomial_b32_branch.txt`,
  `run_branch_full_suite.txt`, `run_guard_reconfirm_branch.txt`.
- **Phase 3a (canary): PASSED, with a crisp enablement finding.** Current optimum-intel 2.1.0
  exports `qwen3_5` ONLY against transformers ~=5.2.0: with 5.5.4 it dies on
  `ImportError: Qwen3_5DynamicCache`; with 5.3.0 its own version gate rejects ("Maximum
  required is 5.2.*"); with 5.2.0 the export succeeds. The fresh Qwen3.5-0.8B export HAS the
  `position_ids` input and **loads and runs on the 2026.4-dev runtime** — closing the drift
  finding from both sides (the old 2026.2-era export lacks that input and fails to load).
  Upstream-reportable optimum-intel material, logged for a future engagement. On the fresh
  export (branch build, commits don't touch these paths): think ids 248068/248069 single-token;
  **auto-detect end-to-end PASS on the VLM path** (`ReasoningConfig(budget=0)` with no ids →
  `</think>` as first token); **the pad-ids mid-generation null CONFIRMED on a thinking VLM**
  (model visibly reasons past budget=12, enforcement never engages) — the strongest form of
  the finding. Logs: `run_canary_export*.txt`, `run_canary_vlm_tests_branch.txt`.
- **Phase 3b: Qwen3.8-27B conversion — four attempts, terminal at the Windows commit limit.**
  Full sequence with verbatim errors (logs `run_27b_conversion*.txt` in `scratch_pr4139/`):
  1. ~03:04-03:29: despite `HF_HUB_CACHE=B:/hf-cache`, huggingface_hub initiated a fresh
     xet-based fetch whose CHUNK cache follows `HF_HOME` (user profile on C:, which sits at
     4.7GB free of 951GB) → `RuntimeError: ... IO Error: There is not enough space on the
     disk. (os error 112)`. Not memory, not the architecture — cache routing onto a full
     system drive. B: (879GB free) and the 18-shard snapshot were never the problem.
  2. `HF_HUB_OFFLINE=1` + cache lookup → `LocalEntryNotFoundError` (optimum's internal
     snapshot request doesn't match what a bare local cache lookup satisfies, even though
     direct `snapshot_download(..., local_files_only=True)` resolves fine).
  3. Local snapshot path → `RuntimeError: Cannot infer the task from a local directory`
     (optimum-cli needs `--task` for local dirs).
  4. Local path + `--task image-text-to-text` + all caches/tmp on B: → got through config and
     into real weight loading, then `OSError: The paging file is too small for this operation
     to complete. (os error 1455)` in `safe_open` — the genuine commit-limit failure
     (31.3GB RAM + fixed 24GB C: pagefile vs ~52GB bf16 source). TERMINAL for this machine
     as configured. Per the sanctioned-outcome rule, recorded rather than fought; the
     genuine retry lever is Blair adding a pagefile on B: (system-settings change,
     deliberately not made by the agent). Attempts 2-3 also yield reusable know-how: the
     working local-dir export recipe for when the pagefile exists is
     `optimum-cli export openvino -m <snapshot path> --task image-text-to-text
     --weight-format int8` with `HF_HOME` and TMP on B:.
  Machine-health observation surfaced to Blair via the team-lead: C: at 4.7GB free of 951GB
  is critically low independent of tonight's work.

**Update (2026-08-21 ~05:15) — head moved again to `2b2e111`; re-anchor cycle complete.**
PlanteAmigor pushed `2b2e111895e1` at 07:58Z ("Translate logit_processor comments from
Chinese to English"), additive on `9391584`. Self-verified scope: exactly one file
(`logit_processor.hpp`, 3 Chinese comment lines → 2 English), and the two OTHER
comment-language nits survive at the new head (mangled "Encodes  thinking and  response" in
both Python binding files; trailing whitespace in `generation_config.cpp` — both re-checked).
Consequences executed:
- Review inline 4 is MOOT (dropped); its surviving related-nit content moved into the review
  body with credit for the quick fix (that is two of our findings he fixed fast — the VLM
  kwargs clobber and the comment language). Review now has 3 inlines; anchors 1-3 verified
  unaffected (their files untouched by the comments-only commit).
- Both drafts re-anchored honestly: "reviewed/built at `9391584`, re-checked against
  `2b2e111` (comment translation only, verified by diff)".
- Branch `feat/thinking-suppression` REBASED onto `2b2e111` (local, unpushed — sanctioned):
  old SHAs `78f53499`/`8760e383`/`adbe4bea` → new `b7fed80c`/`2fa0ccad`/`cf9b750e`. One
  conflict exactly as predicted (our commit deletes the block the translation edited;
  resolved keeping our deletion). Full suite re-run on the rebased branch: 577 ran / 575
  passed (same two harness artifacts). Drafts' items 3/4 language updated to "rebased onto
  today's `2b2e111`" with the post-rebase suite result.
Audits clean; nothing posted, nothing pushed.

**POSTED (2026-08-21 ~11:34-11:35Z / ~07:35 local) — Blair's explicit go ("post it, submit,
and push"), relayed via team-lead; all three external actions executed and verified.**
- Pre-flight: head re-verified still `2b2e111895e1` and zero new comments; ONE new bot
  artifact since the last check — Copilot review id 4991100632 (08:02Z), which is a
  content-free quota-limit failure notice with zero inline comments (same kind as two July
  notices already on the PR). Judgment call, disclosed to the team-lead rather than silently
  absorbed: treated as not-material (head unchanged, no content), proceeded.
- **Branch pushed:** `feat/thinking-suppression` → `blairducrayoppat/openvino.genai`, new
  branch, tip `cf9b750e` verified live via the branches API.
  https://github.com/blairducrayoppat/openvino.genai/tree/feat/thinking-suppression
- One authorized text change before posting: the reply's delivery sentence now states the
  branch is pushed, with the URL.
- **Reply comment posted:** id 5369318698, 2026-08-21T11:34:27Z, 17,958 chars. Verified
  byte-identical to `draft_reply_comment.md` after a first false-alarm diff that was a
  PowerShell array-capture artifact in the verifier itself, not a content difference.
  https://github.com/openvinotoolkit/openvino.genai/pull/4139#issuecomment-5369318698
- **Formal review submitted:** id 4992838307, state COMMENTED, 2026-08-21T11:35:25Z, body
  5,028 chars plus all 3 inline comments accepted at their exact intended anchors
  (`generation_config.cpp:324`, `test_generation_config.py:72`, `py_vlm_pipeline.cpp:403`,
  all side RIGHT — no fallbacks needed), against commit `2b2e111895e1`.
  https://github.com/openvinotoolkit/openvino.genai/pull/4139#pullrequestreview-4992838307
- Payloads built via file-based JSON (`--input`), the workspace's proven-safe method; both
  artifacts fetched back from the API and length/byte-verified.
**Next:** monitor for PlanteAmigor/apaniukov responses — the open decisions on their side are
the multinomial fix shape (single-entry rewrite offered on the pushed branch vs sampler-side
vs the sequence-forcing variant), the C++ auto-detect item (their non-working diff requested),
the structured-output combination (validate()-level rejection proposed), and the VLM pad-ids
prompt-scan finding (fix directions proposed). Blair's earlier VLM-path scope question from
2026-07-23 also remains open with apaniukov.
- **Phase 4 draft updates applied** while conversion runs: reply carries the before/after
  numbers, the "branch is ready" three-commit language (delivery-safe phrasing: "the moment
  you want to pull it"), the demonstrated collision sentence, the thinking-VLM confirmation +
  VLM auto-detect end-to-end proof, head GPU N corrected to 0/8, and a fully updated
  methodology + still-not-verified block. Audits clean (0 dash interrupters).

**Update (2026-08-21 ~00:30) — T4 diagnosed: the VLM prompt-scan null is a real finding, the
most maintainer-relevant of the hardware pass.** The reviewer's re-check flagged the earlier
t4 `close_count=0` as an undiagnosed tested null (mischaracterized in the drafts as "couldn't
test"). Diagnosis protocol executed: branch fully committed, clean rebuild at head `9391584`
(verified: exit 0, tree clean, DLL relinked 00:03 — the "stall" the team-lead's liveness
check saw was just the completion notice landing on an idle session), then the run pair with
saved logs (`run_cpu_llm_t4_control_head.txt`, `run_cpu_vlm_t4_rerun_head.txt`):
- **LLM control** (Qwen3-0.6B, raw prompt ending `<think>\n`, `apply_chat_template=false`,
  `budget=12`, greedy): **forcing fires** — `</think>` at char 43, ~12 tokens in, mid-sentence.
- **VLM re-run** (identical shape, Qwen3-VL-8B): **forcing never fires** — `close_count=0`,
  byte-identical to the first t4 run (reproduced).
Mechanism, code-identified (not runtime-instrumented): `visual_language/pipeline.cpp:801-806`
at head fills the sampler's `prompt_ids` tensor with `pad_token_id` and copies in only the
tokenized KV-cache history — the prompt itself reaches the model as embeddings and never
reaches the sampler as tokens, so `ThinkingBudgetTransform`'s reverse prompt-scan scans pads,
stays IDLE, and mid-generation forcing is structurally dead on `VLMPipeline` (while `budget=0`
bypasses the scan in the constructor, which is why it forces on both paths — every observation
fits). Confirmed the VLM path honors `apply_chat_template=false` (`pipeline.cpp:385`), ruling
out the earlier template hypothesis. Both drafts updated: first-class disclosed finding in the
reply (with fix directions, no new commitment offered), VLM caveat on the review's keep-this
paragraph, unverified-list rewritten to the accurate "runtime-tested null + code-identified
mechanism" form. Also applied this cycle: reviewer wording fixes (T1 "~7 on re-encode";
INLINE 2 verbatim AttributeError), and the save-all-run-logs process rule adopted.

---

### 2026-08-24 — model_server#4428: maintainer accepted the reproducer offer, a fix PR exists (openvino.genai#4332), handoff package prepared, follow-up reply drafted (not posted)

*Plain summary: three new comments landed on model_server#4428 since our 2026-08-20 post, all
positive. The maintainer (mzegla) called the analysis "very extensive," asked us to share the
reproducer scripts and models, and pointed at a fix proposal by Wovchena
(openvino.genai#4332, open, unverified because mzegla can't reproduce on master). lusoris
corroborated our hybrid-vs-SDPA split with their production serving logs and formally accepted
our script handoff to run at production scale on B60/B580. Today's comment (the one Blair
linked) confirms the maintainer may fold the reproducer into their testing routines. A complete
handoff package and a draft reply are ready for Blair's review; nothing posted.*

**New thread state pulled live via `gh` (comment API, not rendered HTML), 2026-08-24:**
1. mzegla, 2026-08-21T13:37:51Z (issuecomment-5370484076): thanks for the analysis; their own
   tests used different models with much smaller prompts/output and saw no errors; asks us to
   **share the reproducer scripts and the models the leaked block states were collected with**;
   links Wovchena's fix proposal https://github.com/openvinotoolkit/openvino.genai/pull/4332,
   explicitly "not verified though as I didn't manage to get reproduction on master so far."
2. lusoris, 2026-08-22T19:14:08Z (issuecomment-5382127474): historical-fleet corroboration —
   their SDPA-era production models (qwen3-coder-30b int4, gpt-oss-20b) never produced the
   `block_manager.hpp:633` assert or leaked-block signature over weeks at scale; the crash class
   appeared only after Gated-DeltaNet hybrids entered the same envelope ("lines up with
   @blairducrayoppat's synthetic split"). Accepts our handoff: "happy to take the script handoff
   rather than duplicate effort," will run it on B60/B580 with production-scale int4 hybrids.
   Also reports a NEW adjacent failure mode (orphaned generations accumulating after abrupt
   client kills until the pipeline hangs; no assert) which mzegla asked them to file separately.
3. mzegla, 2026-08-24T11:53:50Z (issuecomment-5394811549, the comment Blair linked): "the
   reproducer would be great, perhaps we could include something like that in our testing
   routines"; offers lusoris an OVMS build carrying the Wovchena fix (docker vs. baremetal
   question is addressed to lusoris, not us); asks lusoris to file the orphaned-generations
   issue separately (lusoris had not filed it as of this check — verified via issue search,
   their only open issues remain #4428 and #4461).

**PR openvino.genai#4332 state at check time:** open, not draft, not merged, base `master`,
author Wovchena, "Fix stale sequence handling during partial preemption" — makes
`free_sequence()`/`free_sequence_partially()` idempotent for already-freed sequences in
`src/cpp/src/continuous_batching/cache/block_manager.hpp` (+ a regression test). No human
reviews yet (only Copilot bot comments); CI on the head commit green in the sampled window.
This is exactly the code path our reproducer exercised.

**Handoff package built:** `C:\Users\mrbla\oss\scratch_ovms4428\handoff\` (127MB) — README.md
(environment, per-config run commands, caveats, Apache-2.0, AI disclosure), the three scripts
exactly as run, all six raw trial logs unmodified, and the two exact IR exports the reported
numbers came from (each file well under GitHub's 100MB limit). Destination on approval: a
`repro4428/` folder in the public `blairducrayoppat/openvino-contributions` repo (matching the
existing `repro266/` naming convention), pushed at posting time so the link in the reply is live.

**Integrity check done before packaging:** the as-run `stress.py` sets
`cache_interval_multiplier=64` on hybrid runs — a setting the 2026-08-20 posted comment never
mentioned. Source-verified at the pinned `releases/2026/2` checkout (`7dea0459`) that it is
inert when `enable_prefix_caching=False` (all 48 trials): `get_linear_attention_cache_interval`
in `cache_orchestrator.hpp` returns 0 when prefix caching is disabled, before consulting the
multiplier. So the posted comment is not factually wrong, but the README and the draft reply
both disclose it explicitly rather than quietly tidying the script.

**Draft reply:** `C:\Users\mrbla\oss\scratch_ovms4428\draft_reply_4428_followup.md` — NOT
posted. Delivers the package link, the two as-run disclosures, production-scale run guidance
for lusoris, and (Blair-gated scope decision) an offer to run the identical 48-trial matrix
against a master build and a #4332 build on the Arc 140V for a before/after leak count —
directly addressing mzegla's stated inability to reproduce on master.

**Identity note:** Blair referred to himself as "@bducrayoppat" in his request; verified via
`gh api user` and the authorship of our live comment that the actual handle is
**blairducrayoppat**.

**Not done this pass:** no GitHub posts, no public-repo push, no Vikunja label changes (state
unchanged: Active/Testing/Gate:Approved — the gate now pending on the NEW draft is recorded in
the task comment); the master/#4332 verification run not started (Blair's call on scope).

**Next:** Blair reviews `draft_reply_4428_followup.md` + the handoff README; on approval the
posting session pushes `repro4428/` to the public repo first, verifies the link resolves, posts
the reply via `gh api -X POST` (same safe-payload method as 2026-08-20), fetches it back and
diffs. If Blair also approves the master/#4332 offer paragraph, schedule the verification run.

---

### 2026-08-24 — `openvino.genai#4139`: author fixed all six review findings, confirmed our multinomial root cause, and invited the items-3/4 push; rebased swap verified locally, heads-up drafted (not posted)

*Plain summary: Blair linked discussion_r3759862165, which turned out to be apaniukov's known
2026-08-11 items-3/4 comment with no new replies. The real news elsewhere on the PR: PlanteAmigor
pushed five commits addressing every finding from our 2026-08-21 review, implemented our proposed
structured-output rejection with their own hardware repro, confirmed our multinomial diagnosis,
and explicitly invited us to push the base-class swap to the branch after a heads-up. The swap is
now rebased onto the new head and fully verified locally; the heads-up comment is drafted.
Nothing posted, nothing pushed.*

**Live state pulled via `gh` (comment/review/commit APIs + GraphQL reviewThreads, never
WebFetch):** head moved `2b2e111` → `1d29a3aeedf8` (2026-08-22T03:16Z, five commits, all
PlanteAmigor); one new issue comment (id 5377990007, 2026-08-22T04:53Z); zero new inline review
comments; apaniukov silent since 2026-08-11; real CI still gated (labeler only, checked at the
new head); `mergeable_state` still `dirty`.

**The five commits, each re-verified against the diffs (not the author's table):** `46d1cb35`
restores the deleted eos assert byte-identical to the pre-refactor original at `06466bfc`
(including the `eos_token_id == -1` escape) — our review inline 1; `d3cd4920` migrates the
Python config tests to `reasoning_config` and adds `__eq__` — inline 2; `b71cf609` drops the
`!has_value()` guard so a per-call `reasoning_config` kwarg always applies — the exact inline-3
residue; `380e0b83` fixes the comment-literal/whitespace nits; `1d29a3ae` implements the
`validate()` rejection of `reasoning_config` + `structured_output_config` our reply proposed,
with the author's own Qwen3-14B/GPU repro of the `!`-run collision matching our Qwen3-0.6B/CPU
signature. Their quoted sampler line verified exact at `sampler.cpp:981`. Their 3-file
master-merge-conflict claim verified by local `git merge-tree` (two `.pyi` stubs +
`test_generation_config.py`, all else auto-merges). All three of our review inline threads now
`isResolved` by the author.

**The author's comment splits the remaining work exactly as our drafts framed it:** multinomial
fix shape deferred to apaniukov ("If we go with it, just push it"); VLM prompt-scan finding to
become a separate issue (offering us the fix); items 3/4 explicitly invited onto the branch —
"Just push to the `feat/thinking-suppression` branch (a heads-up first so it doesn't clash with
my changes)" — with the parallel-sampling/rollback shape also apaniukov's.

**Local preparation (no external writes):** new branch `feat/thinking-suppression-v2` =
`1d29a3ae` + cherry-picked swap commit only (clean pick, tip `9750f3ce`); the multinomial and
validate()-guard commits deliberately left off since both shapes are apaniukov's call.
`git merge-tree` confirms zero conflicts between our three commits and the five new ones.
Build at the tip (configure ~21s, incremental build ~3m25s; one earlier false start where MSYS
path-mangling made `cmd /c` a no-op — caught by the stale status-file timestamps, rerun via
PowerShell): **18/18 ThinkingBudgetTransformTest** (Blair's 11 + author's 3 + 4 new multi-token
cases), **109/109 Python config tests** (empirically matching the author's claimed count).

**Full-suite flake found and isolated, pre-existing, disclosed in the draft:** across 5
full-suite runs at the v2 tip, 2 were clean (571/573, the two known uninstantiated-real-model
harness artifacts) and 3 each showed ONE wandering 0-ms prefix-caching failure
(`TestBlockManager.PrefixCachingLatestOnlyRestoreKeepsLogicalOffsetWhenOlderBlocksAreMissing`
×2, `TestScheduler.hybrid_prefix_caching_reuses_active_incomplete_linear_attention_checkpoint_
with_cow` ×1). Both pass 5/5 in isolation; neither file is touched by any PR-4139 commit or
ours; control at plain `1d29a3ae` (rebuild without our commit) reproduced the same
`TestBlockManager` failure 1/5 runs. Verdict: pre-existing intermittent test interaction at the
PR head, not the swap. Possibly upstream-reportable on its own (same prefix-caching/linear-
attention-checkpoint subsystem as the `model_server#4428` work; the failing test arrived in
`#3854`) — needs a master-build control before claiming anything externally. Logs:
`scratch_pr4139/run_v2_full_suite.txt`, `run_v2_full_suite_rerun.txt`,
`run_v2_thinkingbudget_filtered.txt`.

**Draft heads-up reply:** `C:\Users\mrbla\oss\scratch_pr4139\draft_heads_up_20260824.md` — NOT
posted. Confirms the six fixes (from the diffs), delivers the heads-up with tip SHA, files
touched, zero-conflict statement, and full test numbers including the disclosed flake; supports
the separate-issue plan for the VLM finding and offers to file it with our evidence; states the
two held-back commits await apaniukov; AI disclosure included. Audits clean (0 em-dashes, 0
dash interrupters, 635 words).

**Push mechanics decided (pending Blair):** update fork branch `feat/thinking-suppression` from
`cf9b750e` to the rebased tip — requires `--force-with-lease` (non-fast-forward). Verified the
posted 2026-08-21 comment cites the branch URL but no commit SHAs, so nothing public dangles;
plan still pushes an archive ref (`archive/thinking-suppression-20260821` at `cf9b750e`) first
as cheap insurance. Push first, then post the heads-up with the live SHA re-verified.

**Vikunja #923:** comment id 3231 added with the full state; labels swapped Gate:Approved →
Gate:Pending-Human via the dedicated label endpoints; title/due (2026-08-25)/priority/
description verified intact afterward (an 8-char desc_len wobble investigated and confirmed a
fetch-serialization artifact, not a change). Access note: the stored project-management API token is now
expired/invalid; this session authenticated via the login endpoint with the stored
user/password instead. Worth refreshing the token.

**Awaiting Blair:** (1) approve posting the heads-up + the fork-branch force-with-lease push;
(2) decide whether we also file the separate VLM prompt-scan issue the author suggested (new
public commitment); (3) nothing else is ours to move — multinomial and guard shapes sit with
apaniukov, the master-merge with the author.

**EXECUTED (2026-08-24 evening / 2026-08-25T00:03Z — Blair's explicit go on both decisions,
relayed via team-lead).** Pre-flight re-verified immediately before acting: head still
`1d29a3ae`, zero new comments/reviews/inline threads since 2026-08-22T05:00Z. Then, in order:
1. **VLM prompt-scan issue FILED:**
   https://github.com/openvinotoolkit/openvino.genai/issues/4368 — duplicate search first (five
   query variants, zero hits), no issue template exists in the repo (`.github/` has only a PR
   template; verified via contents API). Body grounds the mechanism at current master
   `a088679a` (`visual_language/pipeline.cpp:892-895` pad-fill, re-verified in the fetched
   master source, not from the earlier notes), cites the runtime evidence at PR head `9391584`
   with the involved paths confirmed unchanged at `1d29a3ae`, links PlanteAmigor's comment
   proposing the split, presents both fix directions with who-implements left open, and carries
   the AI disclosure. Fetched back post-filing: byte-identical (MATCH). Audits clean (532
   words, 0 dash interrupters). Draft source: `scratch_pr4139/issue_vlm_prompt_scan.md`.
2. **Fork branch updated:** archive ref `archive/thinking-suppression-20260821` pushed first at
   `cf9b750e91c3f3d7635d5d2c6dd359c40380320b`, then `feat/thinking-suppression`
   force-with-lease'd (lease on the exact old SHA) to
   `9750f3ce936a9ff14943e5e7e759146ea00152a5` = head `1d29a3ae` + the rebased items-3/4 swap
   commit only. Both refs verified live via the branches API. Clarification vs. the
   coordinator's wording: the PR head does not change from a fork push — it moves when
   PlanteAmigor merges the fork branch, as with `f90cc875`.
3. **Heads-up comment POSTED:** id 5403120696, 2026-08-25T00:03:02Z, 4,438 chars —
   https://github.com/openvinotoolkit/openvino.genai/pull/4139#issuecomment-5403120696
   The VLM paragraph was updated pre-post to cite the now-real `#4368` (file-then-post
   ordering chosen so the comment carries the issue number). Posted via file-based JSON
   payload (`gh api --input`), fetched back: byte-identical (MATCH).
**Held per plan:** multinomial single-entry-rewrite and parallel-sampling guard commits remain
off the branch (rebased locally, ready) pending apaniukov's design calls.
**Vikunja #923:** comment id 3232 (executed state + links); labels now Active + Gate:Approved
(the Pending-Human removal returned HTTP 500 but did remove the label — verified by re-read,
retry correctly 403'd as already-detached); due date 2026-08-25 → 2026-09-01 via the
backup-then-full-payload flow, task verified intact after. Resolved a red herring from earlier
today: the 1338-vs-1330 desc_len wobble was this session's curl pipeline misdecoding UTF-8 as
cp1252 (four em-dashes × 2 chars), not any change to the task — 1330 is the true length and it
matched exactly before and after the due-date update.
**Ball now with:** PlanteAmigor (merge the fork branch, master-merge), apaniukov (multinomial
shape, guard/rollback shape, #4368 direction). Check-back trigger 2026-09-01.

**Posted (2026-08-24, same day, later).** Blair approved the draft as-is, including the Arc 140V
master/#4332 verification-offer paragraph (that commitment now stands if mzegla accepts).
Execution order and verification:
1. Handoff package published first so the link would be live: committed to the private repo
   (`12aad5c`, tracked so the public-sync removal logic can never delete it) and pushed to the
   public repo as `repro4428/` (commit `2fe741f`, matching the existing `repro266/` convention).
   Verified via the GitHub contents/trees API before posting: all 40 files present, README live.
   https://github.com/blairducrayoppat/openvino-contributions/tree/main/repro4428
2. Re-checked the issue thread immediately before posting: still 10 comments, nothing new after
   issuecomment-5394811549.
3. Posted the reply verbatim via `gh api -X POST` with a python-built JSON payload file. Live at
   https://github.com/openvinotoolkit/model_server/issues/4428#issuecomment-5402900833
   (`2026-08-24T23:32:57Z`, authored blairducrayoppat). Fetched back and diffed against the
   approved draft: content identical; only difference is a single trailing newline appended by
   GitHub, the same cosmetic artifact observed on the 2026-08-20 post.
4. Vikunja #1446: label swapped `Gate:Pending-Human` -> `Gate:Approved` via the dedicated label
   endpoints; posted-state comment added (id 3230) with both live URLs; title, description
   (3815 chars), and due date (2026-09-03 check-back) verified intact afterward.

**Standing commitment created by this post:** if mzegla takes up the offer, run the identical
48-trial matrix on the Arc 140V against (a) a current `openvino.genai` master build and (b) a
build with openvino.genai#4332 applied, reporting before/after leaked-block counts in the same
table format. The next thread check should look for mzegla's response to that offer and to the
package itself.

---

### 2026-08-26 — `openvino.genai#4139`: our swap commit merged as the new PR head; standing review request identified; re-review drafted (not posted)

*Plain summary: Blair saw a "requested your review" banner and asked what it means. Two
findings. First, PlanteAmigor merged our fork branch: the PR head is now literally Blair's
`IStatefulLogitTransformer` swap commit, at the exact SHA we built and tested on 2026-08-24, so
all of that verification applies to the current head with zero staleness. Second, the review
request itself is not new: it dates to 2026-08-22, made alongside the author's "just push to
the branch" comment, and has been standing ever since because Blair hasn't submitted a formal
review since 2026-08-21. A concise re-review is drafted, recommended as COMMENT (not approve);
nothing posted.*

**Live state pulled via `gh` (PR meta, commits, reviews, issue/inline comments with `since=`,
timeline events, GraphQL reviewThreads, check-runs/actions at the head, linked issues), never
WebFetch:**
- **Head moved `1d29a3ae` → `9750f3ce936a`** (by 2026-08-25T15:59Z; Copilot re-request at
  15:59:25Z brackets the push). That SHA is identical to our fork branch tip pushed 2026-08-24:
  PlanteAmigor fast-forwarded the PR branch onto our commit. 23 commits, +654/−4, 13 files.
- **The review request to `blairducrayoppat` was made 2026-08-22T04:56:30Z by PlanteAmigor**
  (same moment apaniukov was re-requested), i.e. with the five-fix-commits comment our
  2026-08-24 session triaged. That session did not record the re-request; recorded now. It
  survives because review requests only clear on a submitted review, and our last review was
  2026-08-21.
- Only other new artifact since 2026-08-25T00:03Z: Copilot review id 5021095316
  (2026-08-25T15:59:42Z), a content-free quota-limit failure notice. **No new human comments,
  reviews, or inline threads; zero reactions on our heads-up; apaniukov silent since
  2026-08-11.**
- CI still fork-gated at the new head (labeler only, ever). `mergeable_state` still `dirty`
  (master conflict: two `.pyi` stubs + `test_generation_config.py` — the author's task).
- Review threads: apaniukov items #2/#3 now `isOutdated` (addressed by the refactor and the
  merged swap) but unresolved; item #1 (C++ auto-detect) still open; one non-outdated Copilot
  thread on `py_generation_config.cpp:492` whose substance the author's `d3cd4920` already
  addressed (resolution is theirs, not ours).
- Linked issues: `#3937` open, quiet since 2026-07-17; `#3946` closed `completed` (June);
  our `#4368` still zero comments.

**Reconciliation of prior verification vs. current head: exact match, no staleness.** The
2026-08-24 local build/test pass ran at branch `feat/thinking-suppression-v2` tip `9750f3ce`
(worktree re-verified today: checked out at that SHA, tree clean) — the same commit object now
at the PR head. So 18/18 ThinkingBudgetTransformTest, 109/109 Python config tests, and the
2026-08-24 full-suite runs (5 runs, 573 ran each; 2 known harness artifacts; 2 runs otherwise
clean, 3 with one pre-existing wandering prefix-caching flake — matching the posted
issuecomment-5403120696) all describe the live head byte-for-byte. CORRECTION 2026-08-26: an
earlier draft of the 08-26 review cited "577 ran / 575 passed" for the head — that figure is
from the 2026-08-21 rebased-branch log (`run_rebased_branch_full_suite.txt`), a different
branch state. The head-SHA logs are `run_v2_full_suite*.txt` (573 ran). Draft fixed before
any posting; the publicly posted comment always had the correct 573. The multinomial before/after numbers (0/13 head, 8/8 with the
held-back fix) were measured at `9391584`/`2b2e111`-era builds; no commit since touches that
sampling path, but the draft states the carry-over explicitly rather than implying a re-run.

**Draft:** `scratch_pr4139\draft_review_20260826.md` — a formal re-review responding to the
standing request. Recommended submission state: **COMMENT, not APPROVE**, for two stated
reasons: (1) the head commit is Blair's own code (self-endorsement), and (2) the multinomial
force-close bug is still live at head on the shipped-defaults sampling path of the target
models, with its fix shape awaiting apaniukov. Draft carries the head-SHA verification numbers,
the five re-verified fix commits, the five open items, and the AI disclosure; no @-mentions
(apaniukov is named, not pinged — Blair can opt to add a ping). Audit: 0 em-dashes, 0 dash
interrupters. NOT posted; posting is Blair's call.

**POSTED 2026-08-27T01:02:48Z** (evening of 2026-08-26 local): Blair reviewed the draft, caught
the ambiguous "my August 25 comment" phrasing (the comment exists — posted 2026-08-25T00:03Z
UTC = Aug 24 evening local; draft now links it directly), which led to finding and fixing the
577→573 figure error above. Blair then approved submission as **COMMENT** (no @-ping to
apaniukov, per his call). Head re-verified at `9750f3ce936a` immediately before posting.
Review id 5036344494, state COMMENTED:
https://github.com/openvinotoolkit/openvino.genai/pull/4139#pullrequestreview-5036344494
This clears the standing 2026-08-22 review request from PlanteAmigor. Next trigger: any
maintainer (apaniukov) response, CI approval, or the author's master-conflict resolution.

**Vikunja #923:** comment id 3236 (full state); labels swapped Gate:Approved →
Gate:Pending-Human via the dedicated label endpoints; due date 2026-09-01 left unchanged as
backstop; title/desc (1330)/priority verified intact after. Access note: the Vikunja MCP
tools now fail at their own `/login` call (400) — the REST fallback (login endpoint with the
stored env credentials) still works and was used; the stored static token remains expired.

**Blair decides:** (1) whether to submit the drafted review; (2) COMMENT vs APPROVE
(recommendation: COMMENT); (3) whether to add an @apaniukov nudge. Nothing else is ours to
move — multinomial/rollback shapes and the auto-detect thread sit with apaniukov, the master
merge with PlanteAmigor.

---

### 2026-08-26 — model_server#4428: mzegla reproduced our package but correctly challenged the leak signal; control experiment confirms he is right; correction draft ready (not posted)

*Plain summary: the maintainer ran our reproducer, got the leak errors, and then asked the right
question: those errors print from the block manager's destructor when the pipeline is destroyed
with requests still running, so are they a bug signal at all, or just what teardown looks like?
We ran a decisive control on the same machine: a perfectly healthy pipeline (under 1% cache
usage, zero pressure) destroyed mid-generation prints the identical errors. He is right. The
"leak" column in our published table is a teardown artifact, not evidence of broken block
accounting. What survives is the other half of our data: hybrid models deterministically wedge
at 100% cache saturation where standard models drain fine. A correction reply is drafted for
Blair's review; owning this correction publicly is the honest move and costs little, since the
maintainer himself already suspected it.*

**Context: the comment Blair linked (issuecomment-5382127474, lusoris, 2026-08-22) was already
triaged in the 2026-08-24 pass** (production-log corroboration of the hybrid-vs-SDPA split +
formal acceptance of our script handoff). The genuinely new item since the last check is
**mzegla, 2026-08-26T08:17:34Z (issuecomment-5422542744)**, which does two things:
1. Reports he reproduced the leak errors with our `repro4428` package, but notes "the errors
   come from block manager destructor when application finishes, so pipeline gets destroyed with
   ongoing requests still being processed. Those assertions might be misleading if this is a
   natural behavior in that situation" and explicitly asks for our read (he is "not that
   familiar with GenAI cache orchestration").
2. Publishes an OVMS docker image built with Wovchena's openvino.genai#4332 fix
   (`zegmil/ovms-gpu:wovchena-genai` on Docker Hub) for lusoris to validate at production
   scale — that part is addressed to lusoris, not us.

**Control experiment (`scratch_ovms4428/teardown_control.py`, logs
`logs_teardown_control*.txt`; same venv/wheel as the published package, openvino-genai
2026.2.1.0, CPU, standard SDPA tiny model, nominal settings):**
- **Case A** — 20 requests, 100 steps (peak cache usage 0.85%, no preemption), pipeline
  destroyed with all 20 in flight: destructor prints the IDENTICAL two errors
  (`BlockManager leaked sequence block tables: 20` / `BlockAllocator leaked blocks ... 16384,
  actual: 16244`). **N=2, byte-identical output both runs.**
- **Case B** — same setup, drained fully (808 steps), then destroyed: clean, no errors. N=1.
- **Case C** — same setup, all 20 cancelled mid-generation by dropping their
  `GenerationHandle`s: everything cancels within one step, teardown clean. N=1. (A first
  buggy run of the script accidentally demonstrated the same thing: handles discarded at
  `add_request` time cancelled every request instantly — kept as corroborating observation.)

**Verdict: mzegla is right.** The destructor errors fire whenever a pipeline is destroyed with
in-flight requests, healthy or not. Our stress harness returns after a 6000-step budget and
lets the pipeline destruct with unfinished requests, so the published table's "leaked block
state on teardown" column is definitionally equal to its "did not drain" column — which is
exactly the perfect correlation we reported without recognizing why. The 2026-08-20 posted
framing ("closely-related, deterministic block-accounting leak in the same code path") does not
survive this control and needs a public correction.

**What survives, re-verified against the raw logs this session:** the attention-type
saturation split. Hybrid: 16/16 trials (8 CPU + 8 GPU, nominal `cache_size=1`) pinned at 100%
cache for effectively the whole run (e.g. `hit_100_steps` 5526-5973 of 6000) and never finished
their 120 requests. SDPA on identical settings: 16/16 drained in 1607-1783 steps at 11.5-13.9%
peak. At artificially matched pressure (`num_kv_blocks=64`): SDPA GPU touched 100% yet still
drained every trial (774-1944 steps); SDPA CPU wedged like the hybrid. The harness genuinely
holds the pipeline in the sustained-saturation/preemption regime where the production assert
lives; it has just never fired the assert itself (the honestly-reported 0/48), and the
production `block_manager.hpp:633` assert is a runtime scheduling-path failure, not a
destructor check — a distinction our earlier comments blurred.

**Draft correction reply:** `scratch_ovms4428/draft_reply_4428_teardown_correction.md` — NOT
posted. Concedes the point with the control data, corrects our framing explicitly, restates
what stands, **withdraws the before/after leaked-block-count offer as framed** (the metric
measures nothing real) and offers a reshaped alternative (mid-generation cancellation churn
under sustained saturation, master vs #4332 — the condition that plausibly creates the
stale-sequence state #4332 makes idempotent), explicitly deferring to mzegla on whether the
synthetic angle still adds signal now that lusoris will test the docker image at production
scale. Also hands lusoris the Case C boundary datum for their future orphaned-generations
issue. AI-disclosure line included. At posting time: push `teardown_control.py` + logs + a
README correction note to the public `repro4428/` folder FIRST, so nobody else misreads the
teardown messages (same publish-then-post ordering as 2026-08-24).

**Needs Blair:** (1) approve posting the correction (public concession + reshaping a standing
public offer = posture); (2) the GPU-driver hold (Vikunja #1446 comment 3233) was justified by
the original before/after matrix, which this correction moots as framed — recommend keeping the
hold until mzegla answers the reshaped offer, then releasing it if he declines.

**Side state checked:** openvino.genai#4332 still open/unmerged, zero human reviews (Copilot
only), untouched since 2026-08-21. lusoris has NOT yet filed the separate orphaned-generations
issue (issue search: their only model_server issues remain #4428 and #4461).

**Not verified / gaps:** controls ran on CPU only with the standard model at N=2/1/1 (the
mechanism is device-independent destructor logic, but GPU was not exercised); no control was
run at saturation (a wedged-then-destroyed healthy-config case is subsumed by Case A's
logic but not separately demonstrated); whether the hybrid wedge is itself a defect (scheduler
livelock) vs. honest oversubscription was not determined — deliberately not claimed either way
in the draft.

**Vikunja #1446:** comment id 3235 (full state + decisions needed); labels swapped
Gate:Approved → Gate:Pending-Human via the dedicated label endpoints; title/description
(3815 chars)/due (2026-09-02/03 tz-display)/priority verified intact after. **Access note:**
the Vikunja MCP tools now fail at their internal login step (HTTP 400) even though direct REST
login with the same stored credentials works — fell back to REST for everything this session;
the MCP server itself needs looking at, not the credentials.

**Next:** Blair reviews the correction draft; on approval, push the package update then post,
fetch back and diff per standing rule. Check-back stays 2026-09-03 (due date unchanged) for
mzegla's answer on the reshaped offer and lusoris's docker-image validation results.

**Update (same day) — independent adversarial review: do-not-post-as-is; draft revised in
place, package corrected locally.** The review (every number re-checked against raw logs, plus
a skeptical-maintainer pass) found one blocker and a set of real defects, all now fixed:
1. **Blocker, verified false claim:** the draft said the control script/logs/README note "are
   now in the repro4428 folder" — none of that was true; the tracked package at
   `C:\Users\mrbla\oss\repro4428\` still carried the retracted "deterministic block-accounting
   leak" framing. Fixed locally: `teardown_control.py` + the three `logs_teardown_control*.txt`
   copied into the package, README reframed (saturation split is the reproduced result) with a
   dated 2026-08-26 correction note. The draft's present-tense sentence stays only because the
   posting checklist (`scratch_ovms4428/POSTING_CHECKLIST_4428_correction.md`) sequences the
   public-mirror push (via Blair's /publish-public-repo flow) BEFORE the comment post.
2. **Factual errors in my own summary stats, caught against the logs:** step range is 1607-1775
   (not "1783" — that number appeared nowhere in the logs); peak-usage floor is 11.36% (say
   11.4-13.9%, not 11.5); the "never exceeded ~14% and always drained" claim was mis-scoped to
   the whole matrix when it holds only for the 16 SDPA-nominal trials.
3. **Tone/altitude:** six mea-culpa restatements cut to two (mzegla diagnosed the artifact
   himself; over-explaining the error repeats the error class); "reduces to" softened to "is
   explained by" (no block-count reconciliation was run); unearned claims removed ("preemption
   regime where the production assert fires" — preemption was never demonstrated, a wedge may
   be a stall; "the condition that plausibly creates the stale-sequence state #4332 makes
   idempotent" → "the condition #4332 targets"; Case A "no preemption" was inferred, now "no
   pressure (0.85% peak)"; "whenever" → "when"); reshaped offer compressed to one conditional
   sentence with the self-deprecations deleted; lusoris tie-in cut to one sentence (and their
   separate-issue intent is conditional, not "plans to file"); disclosure footnote matched to
   the established wording of the two live comments (Claude Code (Anthropic) assistance +
   Blair-reviewed-before-posting + N caveats).
Revised draft: same path, ~340 words + footnote, zero headers, both audits clean. Still NOT
posted; nothing pushed to the public mirror; Blair's two calls (post/don't-post, driver hold)
unchanged.
