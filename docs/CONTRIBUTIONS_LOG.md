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
any of them). Fell back to the Vikunja REST API directly via `VIKUNJA_URL`/`VIKUNJA_TOKEN`/
`VIKUNJA_USER`/`VIKUNJA_PASS`, already present in the environment for this purpose — same
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
