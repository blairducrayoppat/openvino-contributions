"""Standalone reproducer: `Invalid sequence group.` in BlockManager::free_group_partially,
raised from ContinuousBatchingPipeline::step() mid-run (model_server#4428).

Needs only: pip install openvino-genai==2026.4.0.0, and the tiny synthetic hybrid-attention IR
from repro4428/models/ov-tiny-qwen3next-hybrid-dense.

    python repro_assert_4428.py --model <dir> --device GPU --seed 1000
    python repro_assert_4428.py --model <dir> --device CPU --seed 1000 --prefix-caching off

Workload (per seed, deterministic): 3 waves of 12 requests, each wave run until empty before
the next is added; prompts drawn from a 5-prompt pool; min_new_tokens 100, max_new_tokens drawn
from 200-600; each request cancelled with probability 0.75 at a step drawn from 5-60 after it
was added. The KV and linear-attention pools are sized by hand at 64 blocks each.
Only step() is inside the try, so a RAISED line always names a step() call.
"""
import argparse
import random
import sys

import openvino_genai as ovg

PROMPT_POOL = [
    "Explain in detail the history of distributed systems and consensus algorithms, covering "
    "Paxos, Raft, and Byzantine fault tolerance. " * n
    for n in (2, 4, 6, 8, 10)
]


def main():
    p = argparse.ArgumentParser()
    p.add_argument("--model", required=True)
    p.add_argument("--device", default="GPU")
    p.add_argument("--seed", type=int, default=1000)
    p.add_argument("--prefix-caching", default="on", choices=["on", "off"])
    p.add_argument("--max-steps", type=int, default=1500)
    a = p.parse_args()

    sc = ovg.SchedulerConfig()
    sc.num_kv_blocks = 64
    sc.num_linear_attention_blocks = 64
    sc.cache_interval_multiplier = 64
    sc.max_num_seqs = 16
    sc.max_num_batched_tokens = 256
    sc.dynamic_split_fuse = True
    sc.enable_prefix_caching = (a.prefix_caching == "on")
    pipe = ovg.ContinuousBatchingPipeline(a.model, sc, a.device)
    print(f"openvino_genai {ovg.__version__}, device {a.device}, seed {a.seed}, "
          f"prefix caching {a.prefix_caching}", flush=True)

    rng = random.Random(a.seed)
    handles, cancel_at = {}, {}
    next_id = step = cancelled = 0
    for wave in range(3):
        for _ in range(12):
            prompt = rng.choice(PROMPT_POOL)
            gc = ovg.GenerationConfig()
            gc.min_new_tokens = 100
            gc.num_return_sequences = 1
            gc.max_new_tokens = rng.randint(200, 600)
            handles[next_id] = pipe.add_request(next_id, prompt, gc)
            if rng.random() < 0.75:
                cancel_at[next_id] = step + rng.randint(5, 60)
            next_id += 1
        while pipe.has_non_finished_requests() and step < a.max_steps:
            try:
                pipe.step()
            except RuntimeError as exc:
                print(f"RAISED in step() call {step + 1} (wave {wave + 1} of 3, "
                      f"{next_id} requests added, {cancelled} cancelled before this call):\n"
                      f"{exc}", flush=True)
                return 1
            step += 1
            for rid, at in list(cancel_at.items()):
                if step >= at:
                    try:
                        handles[rid].cancel()
                        cancelled += 1
                    except Exception:
                        pass
                    del cancel_at[rid]
    print(f"NO ASSERT: {step} steps, {next_id} requests added, {cancelled} cancelled", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
