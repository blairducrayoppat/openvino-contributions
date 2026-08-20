# Upstream OSS Contribution Workspace

Hands-on upstream contribution work in the OpenVINO ecosystem — reproducing reported bugs from
source, verifying fixes, drafting feature requests, and running hardware-coverage tests that most
external contributors can't (Intel Core Ultra 7 258V / Lunar Lake, Arc 140V / Xe2 iGPU, NPU 4000).

**AI-assisted, human-reviewed.** Investigation, reproducer design, and drafting in this workspace
are done with Claude Code (Anthropic) assistance. Every claim that ships externally — a bug
report, a fix, a test result — is independently verified against real source code and real
hardware runs before it's posted, and stated with exact methodology (hardware, driver/compiler
versions, run counts) rather than as an unqualified assertion. Every external comment states this
explicitly; see `docs/CONTRIBUTIONS_LOG.md` for the full evidence trail behind each contribution.

## Contributor identity

- GitHub handle: **blairducrayoppat**
- CLA: signed (Linux Foundation EasyCLA)

## What's here

- `docs/CONTRIBUTIONS_LOG.md` — the narrative/evidence trail: what was found, how it was
  verified, with exact numbers, for every contribution made from this workspace.
- `repro266/` — a full reproduction case: findings write-up, source-level fix, and the raw
  logs/configs that back it.
- `_verify_npu_guard/` — an NPU-side verification case: reproducer, test harness, and the
  PR/commit text drafted from it.
- Build scripts (`build_*.cmd`, `*_watchdog.sh`) — the from-source build commands used to
  compile OpenVINO / OpenVINO GenAI / the NPU compiler for this hardware, kept so any build here
  is reproducible by someone else on similar hardware.

Upstream source checkouts themselves (`openvino/`, `openvino.genai/`, `npu_compiler/`, etc.) are
not part of this repo — each is its own independent clone with its own git history and, where
relevant, its own fork remote.
