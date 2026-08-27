# GenAI-level reproducer for openvinotoolkit/model_server#4428

Synthetic stress harness for the failure class discussed in
[model_server#4428](https://github.com/openvinotoolkit/model_server/issues/4428):
KV-cache exhaustion under a small static cache in `ContinuousBatchingPipeline`. Full results
and methodology are in
[this comment](https://github.com/openvinotoolkit/model_server/issues/4428#issuecomment-5357627024)
on the issue. What the package reproduces is the hybrid-vs-SDPA saturation split: the hybrid
Gated DeltaNet model deterministically pins the cache at 100% and never finishes its request
load within the step budget at settings where the SDPA control drains comfortably. It does NOT
reproduce the original hard `OPENVINO_ASSERT` at `block_manager.hpp:633` — 0/48 trials hit that
exact assert on this hardware at this scale.

> **Correction note (2026-08-26).** The results comment above described the
> `~BlockManager()`/`~BlockAllocator()` destructor `[ERROR] ... leaked ...` lines as a
> "closely-related, deterministic block-accounting leak". A control experiment
> (`teardown_control.py`, logs in `logs/`) showed those lines are a
> teardown-with-inflight-requests artifact, not independent evidence of a block accounting
> defect: a healthy pipeline at 0.85% peak cache usage, destroyed with 20 requests still in
> flight, prints the identical errors (N=2, byte-identical), while a fully drained pipeline
> and a pipeline whose requests were explicitly cancelled both tear down clean. In the
> 48-trial matrix, the "leaked" trials are exactly the trials that still had unfinished
> requests when the 6000-step budget ran out. Do not read those destructor lines as a crash
> signature; the load-bearing result is the saturation/drain split described above.

## Environment the reported numbers came from

- Windows 11 Pro, Intel Core Ultra 7 258V (Lunar Lake), Arc 140V (Xe2) iGPU, driver 32.0.101.8826
- `openvino-genai==2026.2.1.0` and `openvino==2026.2.1` (official PyPI wheels — exact version match to the issue)
- Model export stack (also recorded in the IRs' own `rt_info`): `optimum-intel 2.1.0`,
  `optimum 2.3.0`, `torch 2.13.0+cpu`, `transformers 4.57.6` (pinned down from 5.x —
  optimum-intel 2.1.0 caps `qwen3_next` export at transformers <= 4.57.6)

## Contents

- `build_models.py` — builds the two tiny (~21-22M param) synthetic HF models:
  (A) hybrid `Qwen3NextConfig` (Gated DeltaNet linear attention + full attention at the real
  4:1 interval, MoE disabled so the FFN matches B), (B) dense `Qwen3Config` (standard SDPA),
  matched hidden size / layers / heads, sharing the real Qwen3-Next tokenizer.
- `stress.py` — the trial driver: 120 long-generation requests (`ignore_eos=True`,
  200-1500 tokens, seeded sampling) in 10 staggered waves against a `SchedulerConfig` with a
  small static cache (`cache_size=1` GB nominal, or `num_kv_blocks=64` for the
  pressure-matched "hard" variant) and `max_num_seqs=16`, stepping synchronously,
  6000-step budget. Trial seeds are fixed (`seed = 1000 + trial_index`).
- `calibrate.py` — early single-request cache-pressure calibration helper (not used for the
  reported numbers, included for completeness).
- `teardown_control.py` — the 2026-08-26 control experiment behind the correction note above:
  Case A destroys a healthy pipeline mid-generation (destructor errors print anyway), Case B
  drains fully first (clean), Case C cancels all requests mid-generation by dropping their
  `GenerationHandle`s (clean).
- `logs/` — raw per-trial output for all 48 reported trials
  (`logs_{cpu,gpu}_{hybrid,standard,standard_hard}.txt`), plus the control-experiment logs
  (`logs_teardown_control*.txt`). Each stress trial prints one Python dict with its full
  effective config and outcome; the `[ERROR] BlockManager leaked sequence block tables ... /
  BlockAllocator leaked blocks ...` lines are the library's own destructor messages — see the
  correction note above for how to read them.
- `models/` — the exact OpenVINO IR exports the reported numbers were collected with:
  `ov-tiny-qwen3next-hybrid-dense` (A) and `ov-tiny-qwen3-standard` (B).

## Running it

```
pip install openvino-genai==2026.2.1.0
# from this directory:
python stress.py CPU hybrid 8          # hybrid model, CPU, 8 trials, cache_size=1
python stress.py GPU hybrid 8
python stress.py CPU standard 8        # standard model, nominal settings
python stress.py GPU standard 8
python stress.py CPU standard 8 hard   # standard model, num_kv_blocks=64 (pressure-matched)
python stress.py GPU standard 8 hard
python teardown_control.py all         # the 2026-08-26 teardown-artifact control (CPU)
```

`stress.py` expects the two IR directories at `./models/ov-tiny-qwen3next-hybrid-dense` and
`./models/ov-tiny-qwen3-standard` (as laid out here). To rebuild the models from scratch
instead: `python build_models.py` (needs `transformers==4.57.6`), then export each output
directory with optimum-intel 2.1.0. The included IRs make that unnecessary for reproduction.

## Caveats, stated up front

- **`cache_interval_multiplier=64` appears in the hybrid runs' config.** It is a leftover
  from early prefix-caching experimentation and is inert in every reported trial: all 48
  trials ran `enable_prefix_caching=False`, and in the `releases/2026/2` source
  (`cache_orchestrator.hpp`, `get_linear_attention_cache_interval`) the checkpoint interval
  is forced to 0 when prefix caching is disabled, before the multiplier is consulted. The
  script is shared exactly as run rather than tidied after the fact.
- **Model weights are randomly initialized and unseeded** (`build_models.py` sets no torch
  seed), so a rebuilt model will not be bit-identical to the included IRs. In the reported
  runs the outcome was insensitive to weights: the counts printed by the destructor at
  teardown (see the correction note) and the first-printed sequence ids were identical across
  CPU vs. GPU at a matched request seed, and across two different weight sets (the MoE and
  dense hybrid variants). With `ignore_eos=True` and seeded per-request `max_new_tokens`, the
  scheduling pattern is fixed by the request seed regardless of sampled token values. The
  exact IRs are included so nothing depends on this.
- **Single-threaded driver**: requests are added and stepped from one Python thread. Any
  concurrency/thread-timing component of the original crash is not exercised.
- **Scale**: ~21-22M param synthetic models, not the 27B/35B-A3B production models from the
  original report. Same mechanism targeted (linear-attention per-slot pre-commit saturating a
  small static cache), different absolute numbers.
- `enable_prefix_caching` was turned off after an early test showed it suppressed cache
  pressure entirely against a small repeated-prompt pool (a test artifact worth re-testing
  with a more diverse prompt pool, not a finding).

## License

Everything in this directory is provided under the Apache License 2.0 (same license as
OpenVINO), so it can be reused or folded into upstream test routines without friction.

## AI-assistance disclosure

The reproducer scripts, the investigation, and this README were produced with Claude Code
(Anthropic) assistance (source-reading, reproducer design, test execution, drafting). All
numbers come from real runs on the hardware listed above; raw logs are included unmodified.
