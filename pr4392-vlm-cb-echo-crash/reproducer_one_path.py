"""Run exactly ONE of the three code paths, in its own process.

The three-path probe crashed with an access violation on one build, and a crash gives no
traceback to attribute it with. One path per process attributes it by which process dies.

  python one_path.py --models-path DIR --device CPU --path string|chat_history|add_request
"""

import argparse
import sys

from openvino_genai import (
    ChatHistory,
    ContinuousBatchingPipeline,
    GenerationConfig,
    GenerationStatus,
    SchedulerConfig,
)

PROMPT = "Unique sampler prompt sentinel 4368"


def cfg() -> GenerationConfig:
    c = GenerationConfig()
    c.num_return_sequences = 1
    c.max_new_tokens = 1
    c.echo = True
    return c


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--models-path", required=True)
    ap.add_argument("--device", required=True)
    ap.add_argument("--path", required=True,
                    choices=["string", "chat_history", "add_request", "load_only"])
    ap.add_argument("--echo", default="true")
    args = ap.parse_args()

    def conf():
        c = cfg()
        if args.echo.lower() != "true":
            c.echo = False
        return c

    print(f"STEP construct device={args.device} echo={args.echo}", flush=True)
    pipe = ContinuousBatchingPipeline(args.models_path, SchedulerConfig(), args.device)
    print("STEP constructed", flush=True)
    if args.path == "load_only":
        print("RESULT load_only ok", flush=True)
        return 0

    if args.path == "string":
        print("STEP generate(list[str])", flush=True)
        res = pipe.generate([PROMPT], generation_config=[conf()])[0]
        print(f"RESULT type={type(res).__name__}", flush=True)
        print(f"RESULT text={res.m_generation_ids[0]!r}", flush=True)
    elif args.path == "chat_history":
        print("STEP generate(list[ChatHistory])", flush=True)
        res = pipe.generate([ChatHistory([{"role": "user", "content": PROMPT}])],
                            generation_config=[conf()])[0]
        print(f"RESULT type={type(res).__name__}", flush=True)
        print(f"RESULT text={res.m_generation_ids[0]!r}", flush=True)
    else:
        print("STEP add_request", flush=True)
        handle = pipe.add_request(4368, PROMPT, generation_config=conf())
        steps = 0
        while handle.get_status() != GenerationStatus.FINISHED:
            pipe.step()
            steps += 1
            if steps > 512:
                print("RESULT did_not_finish", flush=True)
                return 2
        print(f"STEP finished after {steps} step(s)", flush=True)
        out = handle.read_all()[0]
        ids = list(out.generated_ids)
        print(f"RESULT n_ids={len(ids)} any_negative={any(i < 0 for i in ids)}", flush=True)
        print(f"RESULT decoded={pipe.get_tokenizer().decode(ids)!r}", flush=True)
    print("RESULT ok", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
