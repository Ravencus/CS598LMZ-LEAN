#!/usr/bin/env python3
"""Retro-audit existing eval cells: relabel `lean_proof` cells whose final.lean
does not contain the expected theorem name as `signature_mismatch`.

Reads the manifest's `verified_signature` for each problem, finds the expected
theorem/lemma name, and rewrites `outcome.json` in-place for any cell whose
`final.lean` is missing that name.

Safe to re-run (idempotent). Originals are backed up to
`outcome.json.preaudit` only on the first relabel of a given cell.
"""
from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
EVAL_DIR = REPO_ROOT / "final-report" / "data" / "eval_overnight_opencode"
SNAPSHOT_DIR = REPO_ROOT / "final-report" / "data" / "eval_snapshots" / "20260510_083526_partial"
DEFAULT_MANIFEST = SNAPSHOT_DIR / "manifest.json"

_SIG_NAME_RE = re.compile(r"\b(?:theorem|lemma)\s+([A-Za-z_][A-Za-z0-9_']*)")


def extract_expected_theorem_name(signature_block: str) -> str | None:
    if not signature_block:
        return None
    m = _SIG_NAME_RE.search(signature_block)
    return m.group(1) if m else None


def final_proves_expected(final_code: str, expected_name: str) -> bool:
    pattern = re.compile(
        r"^\s*(?:noncomputable\s+)?(?:theorem|lemma)\s+"
        + re.escape(expected_name) + r"\b",
        re.M,
    )
    return bool(pattern.search(final_code))


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--manifest", default=str(DEFAULT_MANIFEST))
    ap.add_argument("--eval-dir", default=str(EVAL_DIR))
    ap.add_argument("--apply", action="store_true",
                    help="actually rewrite outcome.json (default: dry-run)")
    args = ap.parse_args()
    eval_dir = Path(args.eval_dir)

    manifest = json.loads(Path(args.manifest).read_text(encoding="utf-8"))
    expected_by_pid: dict[str, str | None] = {}
    for p in manifest["problems"]:
        expected_by_pid[p["problem_id"]] = extract_expected_theorem_name(
            p.get("verified_signature", "")
        )

    rewrites: list[tuple[str, str, str, str | None]] = []
    skipped_no_name: list[str] = []
    for model_dir in sorted(eval_dir.iterdir()):
        if not model_dir.is_dir():
            continue
        if model_dir.name in {"hub_recall", "trace_compare",
                              "trace_compare_55_vs_opus"}:
            continue
        for cond_dir in sorted(model_dir.iterdir()):
            if not cond_dir.is_dir():
                continue
            for pid_dir in sorted(cond_dir.iterdir()):
                if not pid_dir.is_dir():
                    continue
                pid = pid_dir.name
                outcome_path = pid_dir / "outcome.json"
                final_path = pid_dir / "final.lean"
                if not outcome_path.exists():
                    continue
                try:
                    oc = json.loads(outcome_path.read_text(encoding="utf-8"))
                except json.JSONDecodeError:
                    continue
                if oc.get("outcome") != "lean_proof":
                    continue
                expected_name = expected_by_pid.get(pid)
                if not expected_name:
                    skipped_no_name.append(pid)
                    continue
                final_code = (final_path.read_text(encoding="utf-8")
                              if final_path.exists() else "")
                if final_proves_expected(final_code, expected_name):
                    continue
                rewrites.append((model_dir.name, cond_dir.name, pid, expected_name))
                if args.apply:
                    backup = outcome_path.with_suffix(".json.preaudit")
                    if not backup.exists():
                        backup.write_text(outcome_path.read_text(encoding="utf-8"),
                                          encoding="utf-8")
                    oc["outcome"] = "signature_mismatch"
                    oc["overall_success"] = False
                    oc["signature_ok"] = False
                    oc["expected_theorem_name"] = expected_name
                    oc.setdefault("audit", {})["reclassified_from"] = "lean_proof"
                    outcome_path.write_text(
                        json.dumps(oc, indent=2, ensure_ascii=False),
                        encoding="utf-8",
                    )

    if skipped_no_name:
        print(f"WARN: {len(skipped_no_name)} cells skipped (manifest has no theorem/lemma name):")
        for p in skipped_no_name:
            print(f"  {p}")

    mode = "APPLIED" if args.apply else "DRY-RUN"
    print(f"\n{mode}: {len(rewrites)} lean_proof cells reclassified to signature_mismatch:")
    for m, c, p, name in rewrites:
        print(f"  {m}/{c}/{p}  (expected name: {name})")
    if not args.apply:
        print("\nRe-run with --apply to rewrite outcome.json files.")


if __name__ == "__main__":
    main()
