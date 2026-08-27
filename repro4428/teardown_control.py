"""Control experiment for mzegla's 2026-08-26 question on model_server#4428:
are the ~BlockManager()/~BlockAllocator() '[ERROR] ... leaked ...' messages a
genuine accounting defect signal, or simply what any pipeline prints when it is
destroyed while requests are still in flight?

Method: use the HEALTHY configuration (standard SDPA model, nominal settings,
cache_size=1GB, max cache usage ~12% in the 48-trial matrix, drained 8/8 with
zero leak messages when allowed to finish) and deliberately destroy the pipeline
mid-generation, far from cache pressure. If the same leak errors print, the
destructor messages are a teardown-with-inflight-requests artifact, not evidence
of broken block accounting. If teardown is clean, the messages carry real signal.

Case A: destroy mid-flight (20 requests, 100 steps, ~12% cache max) -> ?
Case B: drain fully, then destroy (same requests) -> expected clean (matches the
        48-trial matrix's drained rows).
"""
import sys, random
import openvino_genai as ovg

MODEL = "./models/ov-tiny-qwen3-standard"

def make_pipe():
    sc = ovg.SchedulerConfig()
    sc.cache_size = 1
    sc.max_num_seqs = 16
    sc.dynamic_split_fuse = True
    sc.enable_prefix_caching = False
    return ovg.ContinuousBatchingPipeline(MODEL, sc, "CPU")

PROMPT = ("Explain in detail the history of distributed systems and consensus "
          "algorithms, covering Paxos, Raft, and Byzantine fault tolerance. " * 4)

def add_requests(pipe, n, rng):
    # Keep the GenerationHandles alive (dropping a handle cancels its request),
    # matching stress.py's handles dict.
    handles = {}
    for i in range(n):
        gc = ovg.GenerationConfig()
        gc.max_new_tokens = 800
        gc.ignore_eos = True
        gc.do_sample = True
        gc.temperature = 1.0
        gc.top_k = 50
        gc.rng_seed = rng.randint(0, 2**31 - 1)
        handles[i] = pipe.add_request(i, PROMPT, gc)
    return handles

def case_a():
    print("=== CASE A: healthy config, destroy mid-flight ===", flush=True)
    rng = random.Random(4428)
    pipe = make_pipe()
    handles = add_requests(pipe, 20, rng)
    max_cache = 0.0
    for _ in range(100):
        if not pipe.has_non_finished_requests():
            break
        pipe.step()
        m = pipe.get_metrics()
        max_cache = max(max_cache, m.cache_usage)
    print(f"CASE A: stepped 100, max_cache_usage={max_cache:.2f}%, "
          f"non_finished={pipe.has_non_finished_requests()}", flush=True)
    del pipe, handles
    print("CASE A: pipeline destroyed (any [ERROR] lines directly above this "
          "line came from the destructor)", flush=True)

def case_b():
    print("=== CASE B: same config, drain fully, then destroy ===", flush=True)
    rng = random.Random(4428)
    pipe = make_pipe()
    handles = add_requests(pipe, 20, rng)
    steps = 0
    while pipe.has_non_finished_requests() and steps < 20000:
        pipe.step()
        steps += 1
    print(f"CASE B: drained in {steps} steps, "
          f"non_finished={pipe.has_non_finished_requests()}", flush=True)
    del pipe, handles
    print("CASE B: pipeline destroyed (clean teardown expected)", flush=True)

def case_c():
    print("=== CASE C: cancel mid-generation (drop handles), step, then destroy ===",
          flush=True)
    rng = random.Random(4428)
    pipe = make_pipe()
    handles = add_requests(pipe, 20, rng)
    for _ in range(100):
        if not pipe.has_non_finished_requests():
            break
        pipe.step()
    print(f"CASE C: stepped 100 with 20 live requests, "
          f"non_finished={pipe.has_non_finished_requests()}", flush=True)
    del handles  # dropping GenerationHandles cancels the requests
    steps_after = 0
    while pipe.has_non_finished_requests() and steps_after < 50:
        pipe.step()
        steps_after += 1
    m = pipe.get_metrics()
    print(f"CASE C: after handle drop: {steps_after} extra steps, "
          f"non_finished={pipe.has_non_finished_requests()}, "
          f"cache_usage={m.cache_usage:.2f}%", flush=True)
    del pipe
    print("CASE C: pipeline destroyed (clean teardown would mean the "
          "cancellation path releases blocks correctly)", flush=True)

if __name__ == "__main__":
    which = sys.argv[1] if len(sys.argv) > 1 else "all"
    if which in ("a", "all"):
        case_a()
    if which in ("b", "all"):
        case_b()
    if which in ("c", "all"):
        case_c()
    print("DONE", flush=True)
