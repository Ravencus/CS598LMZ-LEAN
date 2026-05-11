#!/usr/bin/env python3
"""Aggregate Arm B (OpenCode agentic) outcome.json cells into a summary.

Walks data/eval_overnight_opencode/<model>/<condition>/<pid>/outcome.json
and produces a leaderboard parallel to Arm A's data/eval_snapshots/.../aggregate.json.

Schema mirrors Arm A's `leaderboard` block plus Arm B-specific fields:
  - mcp_calls_summary    : {median, mean, max} of mcp_calls per (model, condition)
  - cost_summary         : {total_usd, mean_per_cell} per model
  - wall_summary         : {median_s, mean_s, p90_s} per (model, condition)
  - source_breakdown     : count of cells by final_proof_source
"""
from __future__ import annotations

import argparse
import json
import statistics
from collections import defaultdict
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[2]
EVAL_DIR = REPO_ROOT / "final-report" / "data" / "eval_overnight_opencode"

OUTCOME_KEYS = [
    "lean_proof", "sympy_rescue", "signature_mismatch", "instruction_violation",
    "compile_fail", "model_timeout", "wall_budget_exceeded", "no_final_proof",
]


def collect_cells(eval_dir: Path) -> list[dict]:
    cells: list[dict] = []
    if not eval_dir.exists():
        return cells
    for outcome_path in eval_dir.rglob("outcome.json"):
        try:
            cells.append(json.loads(outcome_path.read_text(encoding="utf-8")))
        except (json.JSONDecodeError, OSError):
            continue
    return cells


def _pct(num: int, denom: int) -> float:
    return 0.0 if denom == 0 else round(num / denom, 4)


def _stat_pack(xs: list[float]) -> dict:
    if not xs:
        return {"n": 0}
    sorted_xs = sorted(xs)
    n = len(sorted_xs)
    return {
        "n": n,
        "median": round(statistics.median(sorted_xs), 4),
        "mean": round(statistics.mean(sorted_xs), 4),
        "max": round(max(sorted_xs), 4),
        "p90": round(sorted_xs[max(0, int(0.9 * n) - 1)], 4),
    }


def aggregate(cells: list[dict]) -> dict:
    by_mc: dict[tuple[str, str], list[dict]] = defaultdict(list)
    for c in cells:
        key = (c.get("model", "?"), c.get("condition", "?"))
        by_mc[key].append(c)

    leaderboard: dict[str, dict] = {}
    for (model, cond), bucket in by_mc.items():
        n = len(bucket)
        outcomes = {k: 0 for k in OUTCOME_KEYS}
        for c in bucket:
            o = c.get("outcome", "compile_fail")
            outcomes[o] = outcomes.get(o, 0) + 1
        pass_n = outcomes["lean_proof"] + outcomes["sympy_rescue"]
        wall_xs = [float(c.get("wall_seconds", 0)) for c in bucket]
        mcp_xs = [int(c.get("mcp_calls", 0)) for c in bucket]
        mcp_xs_pass = [int(c.get("mcp_calls", 0)) for c in bucket
                        if c.get("overall_success")]
        budget_hit = sum(1 for c in bucket if c.get("budget_hit_event"))
        cost_xs = [float(c.get("total_cost_usd", 0)) for c in bucket]
        sources = defaultdict(int)
        for c in bucket:
            sources[c.get("final_proof_source") or "none"] += 1
        leaderboard.setdefault(model, {})[cond] = {
            "n": n,
            "pass_rate": _pct(pass_n, n),
            "outcomes": outcomes,
            "budget_hit_cells": budget_hit,
            "wall_seconds": _stat_pack(wall_xs),
            "mcp_calls_all": _stat_pack(mcp_xs),
            "mcp_calls_passing": _stat_pack(mcp_xs_pass),
            "cost_total_usd": round(sum(cost_xs), 6),
            "cost_mean_per_cell_usd": round(
                sum(cost_xs) / n, 6) if n else 0.0,
            "source_breakdown": dict(sources),
        }

    sympy_ablation: dict[str, dict] = {}
    for model, by_cond in leaderboard.items():
        if "lean_only" in by_cond and "with_sympy" in by_cond:
            d = by_cond["with_sympy"]["pass_rate"] - by_cond["lean_only"]["pass_rate"]
            sympy_ablation[model] = {
                "lean_only": by_cond["lean_only"]["pass_rate"],
                "with_sympy": by_cond["with_sympy"]["pass_rate"],
                "delta": round(d, 4),
            }

    return {
        "n_cells_total": len(cells),
        "leaderboard": leaderboard,
        "sympy_ablation": sympy_ablation,
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--eval-dir", default=str(EVAL_DIR))
    ap.add_argument("--out", default=str(EVAL_DIR / "aggregate.json"))
    args = ap.parse_args()

    cells = collect_cells(Path(args.eval_dir))
    summary = aggregate(cells)
    Path(args.out).parent.mkdir(parents=True, exist_ok=True)
    Path(args.out).write_text(
        json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8",
    )

    # Compact human-readable digest.
    print(f"Cells aggregated: {summary['n_cells_total']}")
    print(f"\n{'Model':<22} {'Cond':<12} {'n':>3} {'pass':>6} {'lean':>4} {'symp':>4} {'walltm':>7}")
    print("-" * 70)
    for model, by_cond in summary["leaderboard"].items():
        for cond, d in by_cond.items():
            outc = d["outcomes"]
            print(f"{model:<22} {cond:<12} {d['n']:>3} {d['pass_rate']:>6.2f} "
                  f"{outc['lean_proof']:>4} {outc['sympy_rescue']:>4} "
                  f"{d['wall_seconds'].get('median', 0):>7.1f}")
    if summary["sympy_ablation"]:
        print(f"\nSympy ablation (Δ pass_rate):")
        for model, d in summary["sympy_ablation"].items():
            sign = "+" if d["delta"] >= 0 else ""
            print(f"  {model:<22} {d['lean_only']:.2f} → {d['with_sympy']:.2f}  ({sign}{d['delta']:.2f})")
    print(f"\nWritten to {args.out}")


if __name__ == "__main__":
    main()
