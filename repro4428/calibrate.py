"""Calibration: find a cache_size / concurrency combination that drives cache_usage to 100%
and forces preemption, for both the hybrid and standard tiny models, on CPU first (fast,
no GPU driver dependency) before spending GPU time.
"""
import sys, time
import openvino_genai as ovg

MODEL_PATHS = {
    "standard": "./models/ov-tiny-qwen3-standard",
    "hybrid": "./models/ov-tiny-qwen3next-hybrid",
}

def run(label, model_path, device, cache_size_gb, max_num_seqs, n_requests, max_new_tokens, max_steps=2000):
    sc = ovg.SchedulerConfig()
    sc.cache_size = int(cache_size_gb)
    sc.max_num_seqs = max_num_seqs
    sc.dynamic_split_fuse = True
    sc.enable_prefix_caching = False
    pipe = ovg.ContinuousBatchingPipeline(model_path, sc, device)
    gc = ovg.GenerationConfig()
    gc.max_new_tokens = max_new_tokens
    gc.ignore_eos = True
    gc.do_sample = False

    prompt = "Explain in detail the history of distributed systems and consensus algorithms, covering Paxos, Raft, and Byzantine fault tolerance. " * 6

    handles = []
    for i in range(n_requests):
        h = pipe.add_request(i, prompt, gc)
        handles.append(h)

    max_seen = 0.0
    hit_100 = False
    step_count = 0
    crashed = False
    err = None
    t0 = time.time()
    try:
        while pipe.has_non_finished_requests() and step_count < max_steps:
            pipe.step()
            step_count += 1
            m = pipe.get_metrics()
            if m.cache_usage > max_seen:
                max_seen = m.cache_usage
            if m.cache_usage >= 99.9:
                hit_100 = True
    except Exception as e:
        crashed = True
        err = f"{type(e).__name__}: {e}"
    elapsed = time.time() - t0
    print(f"[{label}] device={device} cache_size={cache_size_gb}GB max_num_seqs={max_num_seqs} "
          f"n_req={n_requests} max_new_tokens={max_new_tokens} -> steps={step_count} "
          f"max_cache_usage={max_seen:.1f}% hit_100={hit_100} crashed={crashed} err={err} "
          f"elapsed={elapsed:.1f}s")
    return crashed, err, max_seen, hit_100, step_count

if __name__ == "__main__":
    device = sys.argv[1] if len(sys.argv) > 1 else "CPU"
    # cache_size is int GB; 1 is the minimum "static" (nonzero) value, mirroring the
    # report's --cache_size 4 (smallest static allocation this API allows).
    for label, path in MODEL_PATHS.items():
        for n_requests, max_new_tokens in [(6, 200), (10, 400), (16, 800)]:
            run(label, path, device, cache_size_gb=1, max_num_seqs=16, n_requests=n_requests, max_new_tokens=max_new_tokens)
