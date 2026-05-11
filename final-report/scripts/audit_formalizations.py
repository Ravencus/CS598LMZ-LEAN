"""
Audit Stage-7 formalizations for English↔Lean faithfulness.

For each problem, ask gpt-5.5 (judge model) whether the Stage-7 Lean statement
faithfully represents the English statement. Flag mismatches before we use them
in the overnight 50-problem run.

Three failure modes to catch:
  - VACUOUS: free variables left unconstrained, claim trivially false
            (e.g., `(S : ℕ → ℝ) : ∀N, S N < 3` — no hypothesis on S)
  - MISMATCH: English says X, formal asserts Y (different claim)
  - UNCERTAIN: can't tell (mark for human review)
  - FAITHFUL: looks correct
"""

from __future__ import annotations

import json
import sys
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from unified_harness import codex_call

FORMALIZATIONS = Path("/workspace/final-presentation/d2_curation_v2/data/formalizations")
NODES = Path("/workspace/final-presentation/d2_curation_v2/data/dataset_v2/nodes")
OUT_FILE = Path("/workspace/final-report/data/phase1_smoke/formalization_audit.json")

JUDGE_MODEL = "gpt-5.5"
SAMPLE_SIZE = 60   # audit 60 to leave room for ~50 clean ones after filtering
MAX_WORKERS = 4

JUDGE_PROMPT = """You are auditing whether a Lean 4 + Mathlib formalization faithfully represents an English math statement.

ENGLISH STATEMENT:
{statement_en}

LEAN FORMALIZATION:
{lean_code}

Classify the faithfulness:
- FAITHFUL  — Lean correctly captures the English claim (allowing standard notational conventions like e(x) = exp(2πix), index shifts to avoid log(0), etc.)
- VACUOUS   — Lean has unconstrained free variables that make the claim trivially false or undefined (e.g., `(S : ℕ → ℝ) : ∀ N, S N < 3` — no hypothesis on S)
- MISMATCH  — Lean asserts a clearly different claim than the English (e.g., English says "approximate √2", Lean says "harmonic series diverges")
- UNCERTAIN — you can't tell without more context

Output ONLY a single JSON object on one line, no markdown, no commentary:
{{"verdict": "FAITHFUL|VACUOUS|MISMATCH|UNCERTAIN", "reason": "<brief one-sentence justification>"}}"""


def load_candidates() -> list[dict]:
    """Load Stage-7 successes that pass basic filters."""
    out = []
    for d in sorted(FORMALIZATIONS.iterdir()):
        if not d.is_dir(): continue
        sp = d / "summary.json"
        if not sp.exists(): continue
        s = json.loads(sp.read_text())
        if not s.get("success"): continue
        code = s.get("final_code") or ""
        if ":= by\n  sorry" not in code and ":= by sorry" not in code: continue
        if len(code) > 600: continue
        nf = NODES / f"{s['problem_id']}.json"
        if not nf.exists(): continue
        n = json.loads(nf.read_text())
        if n.get("problem_type") not in {"theorem", "lemma", "exercise"}: continue
        out.append({
            "problem_id": s["problem_id"],
            "statement_en": n.get("statement_en", ""),
            "lean_code": code,
            "difficulty": n.get("difficulty"),
            "problem_type": n.get("problem_type"),
            "domain": n.get("domain"),
        })
    return out


def parse_verdict(text: str) -> dict:
    """Extract first JSON object from judge output."""
    if not text: return {"verdict": "UNCERTAIN", "reason": "empty response"}
    s = text.strip()
    # Strip code fences if any
    import re
    m = re.search(r"```(?:json)?\s*\n?(.*?)\n?```", s, re.DOTALL)
    if m: s = m.group(1).strip()
    # Find first JSON object
    m = re.search(r"\{.*?\}", s, re.DOTALL)
    if not m: return {"verdict": "UNCERTAIN", "reason": f"no JSON in response: {text[:120]!r}"}
    try:
        d = json.loads(m.group(0))
        if "verdict" not in d:
            d["verdict"] = "UNCERTAIN"
        if "reason" not in d:
            d["reason"] = ""
        return d
    except Exception as e:
        return {"verdict": "UNCERTAIN", "reason": f"parse failed: {e}"}


def judge_one(item: dict) -> dict:
    prompt = JUDGE_PROMPT.format(
        statement_en=item["statement_en"],
        lean_code=item["lean_code"],
    )
    text, meta = codex_call(JUDGE_MODEL, prompt, timeout=180)
    verdict = parse_verdict(text or "")
    return {
        **item,
        "verdict": verdict["verdict"],
        "reason": verdict["reason"],
        "judge_wall_seconds": meta.get("wall_seconds"),
        "judge_raw": (text or "")[:500],
    }


def main():
    candidates = load_candidates()
    print(f"Total Stage-7 success candidates after filter: {len(candidates)}")

    # Load already-audited problem_ids and skip them
    existing_results = []
    if OUT_FILE.exists():
        existing_results = json.loads(OUT_FILE.read_text())
    audited_ids = {r["problem_id"] for r in existing_results}
    print(f"Already audited: {len(audited_ids)}")

    remaining = [c for c in candidates if c["problem_id"] not in audited_ids]
    print(f"Remaining to audit: {len(remaining)}")
    print()

    if not remaining:
        print("Nothing new to audit; aborting.")
        sample = []
    else:
        sample = remaining
    print(f"Auditing {len(sample)} via {JUDGE_MODEL}...")
    print()

    OUT_FILE.parent.mkdir(parents=True, exist_ok=True)

    results = list(existing_results)  # preserve prior
    with ThreadPoolExecutor(max_workers=MAX_WORKERS) as ex:
        futures = {ex.submit(judge_one, item): item["problem_id"] for item in sample}
        for fut in as_completed(futures):
            pid = futures[fut]
            try:
                r = fut.result()
                results.append(r)
                v = r["verdict"]
                tag = {"FAITHFUL": "✓", "VACUOUS": "⚠V", "MISMATCH": "⚠M", "UNCERTAIN": "?"}.get(v, "?")
                print(f"  [{tag}] {pid:<45} verdict={v:<10} reason={r['reason'][:80]}")
            except Exception as e:
                print(f"  [ERR] {pid}: {e}")

    OUT_FILE.write_text(json.dumps(results, indent=2, ensure_ascii=False))

    # Summary
    from collections import Counter
    counts = Counter(r["verdict"] for r in results)
    print()
    print(f"=== AUDIT SUMMARY (cumulative {len(results)} audited) ===")
    for v, n in counts.most_common():
        pct = 100 * n / len(results)
        print(f"  {v:<10} {n:>3} ({pct:>4.1f}%)")
    print()
    flagged = [r for r in results if r["verdict"] in ("VACUOUS", "MISMATCH")]
    print(f"FLAGGED (problematic): {len(flagged)}")
    for r in flagged[:10]:
        print(f"  - {r['problem_id']:<45} {r['verdict']:<10} {r['reason'][:90]}")
    print()
    print(f"Audit results saved: {OUT_FILE}")


if __name__ == "__main__":
    main()
