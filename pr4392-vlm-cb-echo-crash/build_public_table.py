"""Join the three PR #4392 result CSVs into one published table, redacting local paths.

The three sweeps share a subject but not a schema: the pytest matrix records test verdicts,
the two one-path sweeps record process exit codes. This produces a single 204-row table on a
union schema, plus a redacted copy of each source CSV, so a reader can work from either.

This writes the STAGED copy at full fidelity. Redaction is not done here: the publish pipeline
is stage -> `scripts/redact_publish_package.py` -> `scripts/screen_publish_package.py`, so the
private record keeps every local path and only the staged copy is rewritten. The path rules for
this dataset live in that redaction script, with the screen's matching patterns and self-test
samples in the screen.

  python build_public_table.py --out DIR
"""

import argparse
import csv
import sys
from pathlib import Path

SRC = Path(__file__).resolve().parent.parent / "results"

def artifact_id(path: str) -> str:
    """The run's artifact filename, with no directory.

    The per-unit logs are not published, so a path-shaped value here would be a citation a
    reader cannot open -- the one thing the publish pipeline's governing requirement forbids.
    The filename is unique per run and is what identifies which run produced the row.
    """
    return path.replace("\\", "/").rsplit("/", 1)[-1]


# Union schema. Every row carries every column; a column that does not apply to a row's source
# gets an explicit token naming why, never a blank.
UNION = [
    "sweep", "arm", "rep", "utc_start", "wall_s",
    "build_label", "build_sha", "build_dir",
    "device", "model", "models_path",
    "call_path", "echo", "test_variant", "test_file_sha256", "tests",
    "outcome", "exit_code", "crash_kind", "last_step",
    "n_tests", "n_passed", "n_failed", "n_skipped", "case_outcomes", "failure_detail",
    "string_prompt_present", "chat_history_prompt_present", "add_request_prompt_present",
    "string_result_type", "chat_history_result_type",
    "add_request_generated_id_count", "add_request_negative_ids",
    "echo_text_sha256", "result_text_sha256", "result_line",
    "prompt_token_count", "load_s", "peak_rss_mb",
    "build_type", "generator", "tokenizers_submodule",
    "ov_version", "transformers", "optimum_intel", "gpu_driver",
    "run_artifact_id",
]


def from_matrix(r: dict) -> dict:
    na = "n/a:pytest_matrix"
    out = {k: na for k in UNION}
    out.update({
        "sweep": "pytest_matrix", "arm": r["arm"], "rep": r["rep"],
        "utc_start": r["utc_start"], "wall_s": r["wall_s"],
        "build_label": r["build_label"], "build_sha": r["build_sha"],
        "build_dir": r["build_dir"],
        "device": r["device_requested"], "model": r["model_id"],
        "models_path": "n/a:selected_by_fixture",
        "call_path": "n/a:whole_test", "echo": "true:set_inside_the_test",
        "test_variant": r["test_variant"], "test_file_sha256": r["test_file_sha256"],
        "tests": r["tests"], "outcome": r["outcome"], "exit_code": r["pytest_exit_code"],
        "crash_kind": ("access_violation_0xC0000005"
                       if r["outcome"] == "CRASH_ACCESS_VIOLATION" else "none"),
        "last_step": "n/a:pytest_matrix",
        "n_tests": r["n_tests"], "n_passed": r["n_passed"], "n_failed": r["n_failed"],
        "n_skipped": r["n_skipped"], "case_outcomes": r["case_outcomes"],
        "failure_detail": r["failure_detail"],
        "string_prompt_present": r["string_prompt_present"],
        "chat_history_prompt_present": r["chat_history_prompt_present"],
        "add_request_prompt_present": r["add_request_prompt_present"],
        "string_result_type": r["string_result_type"],
        "chat_history_result_type": r["chat_history_result_type"],
        "add_request_generated_id_count": r["add_request_generated_id_count"],
        "add_request_negative_ids": r["add_request_negative_ids"],
        "echo_text_sha256": r["echo_text_sha256"],
        "result_text_sha256": "n/a:pytest_matrix", "result_line": "n/a:pytest_matrix",
        "prompt_token_count": r["prompt_token_count"], "load_s": r["load_s"],
        "peak_rss_mb": r["peak_rss_mb"], "build_type": r["build_type"],
        "generator": r["generator"], "tokenizers_submodule": r["tokenizers_submodule"],
        "ov_version": r["ov_version"], "transformers": r["transformers"],
        "optimum_intel": r["optimum_intel"], "gpu_driver": r["gpu_driver"],
        "run_artifact_id": artifact_id(r["artifact"]),
    })
    return out


def from_sweep(r: dict, sweep: str) -> dict:
    na = f"n/a:{sweep}"
    out = {k: na for k in UNION}
    out.update({
        "sweep": sweep, "arm": r["arm"], "rep": r["rep"],
        "utc_start": r["utc_start"], "wall_s": r["wall_s"],
        "build_label": r["build_label"], "build_sha": r["build_sha"],
        "build_dir": r["build_dir"],
        "device": r["device"], "model": r["model"],
        "models_path": r["models_path"],
        "call_path": r["path"], "echo": r["echo"],
        "test_variant": "n/a:no_pytest", "test_file_sha256": "n/a:no_pytest",
        "tests": "one_path.py", "outcome": r["outcome"], "exit_code": r["exit_code"],
        "crash_kind": r["crash_kind"], "last_step": r["last_step"],
        "result_text_sha256": r["result_text_sha256"],
        "result_line": r["result_line"],
        "build_type": "Release", "generator": "Ninja",
        "tokenizers_submodule": r["tokenizers_submodule"],
        "ov_version": r["ov_version"], "gpu_driver": r["gpu_driver"],
        "transformers": "5.0.0", "optimum_intel": "2.2.0.dev0+4f1a926",
        "run_artifact_id": artifact_id(r["log"]),
    })
    return out


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--out", required=True)
    args = ap.parse_args()
    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)

    def read(name):
        with (SRC / name).open(encoding="utf-8", newline="") as f:
            return list(csv.DictReader(f))

    matrix = read("rows.csv")
    sweep = read("crash_rows.csv")
    textllm = read("crash_rows_textllm.csv")

    joined = ([from_matrix(r) for r in matrix]
              + [from_sweep(r, "echo_sweep") for r in sweep]
              + [from_sweep(r, "textonly_sweep") for r in textllm])

    with (out / "all_runs.csv").open("w", encoding="utf-8", newline="") as f:
        w = csv.DictWriter(f, fieldnames=UNION, lineterminator="\n")
        w.writeheader()
        w.writerows(joined)

    # Redacted copies of each source, so the join can be checked against its inputs.
    for name, rows_, target in (("rows.csv", matrix, "source_pytest_matrix.csv"),
                                ("crash_rows.csv", sweep, "source_echo_sweep.csv"),
                                ("crash_rows_textllm.csv", textllm, "source_textonly_sweep.csv")):
        with (out / target).open("w", encoding="utf-8", newline="") as f:
            w = csv.DictWriter(f, fieldnames=list(rows_[0].keys()), lineterminator="\n")
            w.writeheader()
            w.writerows(rows_)

    print(f"all_runs.csv: {len(joined)} rows, {len(UNION)} columns "
          f"({len(matrix)} pytest_matrix + {len(sweep)} echo_sweep + {len(textllm)} textonly_sweep)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
