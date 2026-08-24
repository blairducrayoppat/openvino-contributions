"""Heavier stress reproducer: staggered arrivals, prefix caching on (matches the original
OVMS report's --enable_prefix_caching true), heavy oversubscription, multiple waves, to
try to force the repeated-preemption path in scheduler.hpp (_apply_preemption /
_preempt_by_recompute) into hitting block_manager.hpp:633
(OPENVINO_ASSERT(m_block_table.count(seq_id) > 0)).
"""
import sys, time, random
import openvino_genai as ovg

MODEL_PATHS = {
    "standard": "./models/ov-tiny-qwen3-standard",
    "hybrid": "./models/ov-tiny-qwen3next-hybrid-dense",
}

PROMPT_POOL = [
    "Explain in detail the history of distributed systems and consensus algorithms, covering Paxos, Raft, and Byzantine fault tolerance. " * n
    for n in (2, 4, 6, 8, 10)
]

def run_trial(label, model_path, device, trial_idx, seed,
              cache_size_gb=1, num_kv_blocks=None, max_num_seqs=16, enable_prefix_caching=False,
              cache_interval_multiplier=None, waves=10, per_wave=12,
              min_new_tokens=100, max_new_tokens_range=(200, 1500), max_steps=6000):
    rng = random.Random(seed)
    sc = ovg.SchedulerConfig()
    if num_kv_blocks is not None:
        sc.num_kv_blocks = int(num_kv_blocks)
    else:
        sc.cache_size = int(cache_size_gb)
    sc.max_num_seqs = max_num_seqs
    sc.dynamic_split_fuse = True
    sc.enable_prefix_caching = enable_prefix_caching
    if cache_interval_multiplier is not None:
        sc.cache_interval_multiplier = cache_interval_multiplier

    pipe = ovg.ContinuousBatchingPipeline(model_path, sc, device)

    next_id = 0
    handles = {}
    crashed = False
    err = None
    step_count = 0
    max_cache_seen = 0.0
    hit_100_steps = 0
    t0 = time.time()
    try:
        for wave in range(waves):
            for _ in range(per_wave):
                gc = ovg.GenerationConfig()
                gc.max_new_tokens = rng.randint(*max_new_tokens_range)
                gc.ignore_eos = True
                gc.do_sample = True
                gc.temperature = 1.0
                gc.top_k = 50
                gc.rng_seed = rng.randint(0, 2**31 - 1)
                prompt = rng.choice(PROMPT_POOL)
                h = pipe.add_request(next_id, prompt, gc)
                handles[next_id] = h
                next_id += 1
            # step a bounded number of times per wave to let this wave's requests
            # partially process (and collide with the previous wave's still-running
            # long sequences) before adding the next wave - simulates a steady stream
            # of arriving requests against already-long-running ones, like the
            # production traffic described in the report.
            steps_this_wave = rng.randint(15, 40)
            for _ in range(steps_this_wave):
                if not pipe.has_non_finished_requests():
                    break
                pipe.step()
                step_count += 1
                m = pipe.get_metrics()
                if m.cache_usage > max_cache_seen:
                    max_cache_seen = m.cache_usage
                if m.cache_usage >= 99.9:
                    hit_100_steps += 1
                if step_count >= max_steps:
                    break
            if step_count >= max_steps:
                break
        # drain remaining
        while pipe.has_non_finished_requests() and step_count < max_steps:
            pipe.step()
            step_count += 1
            m = pipe.get_metrics()
            if m.cache_usage > max_cache_seen:
                max_cache_seen = m.cache_usage
            if m.cache_usage >= 99.9:
                hit_100_steps += 1
    except Exception as e:
        crashed = True
        err = f"{type(e).__name__}: {e}"
    elapsed = time.time() - t0
    result = dict(label=label, device=device, trial=trial_idx, seed=seed,
                  cache_size_gb=cache_size_gb, num_kv_blocks=num_kv_blocks, max_num_seqs=max_num_seqs,
                  enable_prefix_caching=enable_prefix_caching,
                  cache_interval_multiplier=cache_interval_multiplier,
                  waves=waves, per_wave=per_wave, total_requests=next_id,
                  steps=step_count, max_cache_usage=max_cache_seen,
                  hit_100_steps=hit_100_steps, crashed=crashed, err=err, elapsed=elapsed)
    print(result, flush=True)
    return result

if __name__ == "__main__":
    device = sys.argv[1] if len(sys.argv) > 1 else "CPU"
    label = sys.argv[2] if len(sys.argv) > 2 else "hybrid"
    n_trials = int(sys.argv[3]) if len(sys.argv) > 3 else 5
    hard = len(sys.argv) > 4 and sys.argv[4] == "hard"
    cim = 64 if label == "hybrid" else None
    nkvb = 64 if hard else None  # equal-cache-pressure variant for the standard model
    results = []
    for t in range(n_trials):
        r = run_trial(label, MODEL_PATHS[label], device, t, seed=1000 + t,
                       cache_interval_multiplier=cim, num_kv_blocks=nkvb)
        results.append(r)
    n_crash = sum(1 for r in results if r["crashed"])
    print(f"SUMMARY {label} {device}: {n_crash}/{len(results)} crashed")
