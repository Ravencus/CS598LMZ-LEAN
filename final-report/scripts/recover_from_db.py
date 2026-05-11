#!/usr/bin/env python3
"""Reconstruct deleted outcome cells from OpenCode's session DB.

OpenCode stores every `opencode run` invocation as a session in
~/.local/share/opencode/opencode.db. Each session has a sequence of `part`
rows that mirror what we capture in stream.jsonl. When cell directories were
deleted (loss of stream.jsonl + outcome.json), the underlying session data is
still in the SQLite DB and is reconstructable.

This script:
  1. Pulls every session whose first user-message has model.providerID set
     (i.e., a non-trivial run, not a config probe).
  2. Reads the prompt, matches against the manifest to identify
     (model, condition, problem_id).
  3. Replays the part stream, computing the same fields opencode_runner.py
     would have produced.
  4. Writes outcome.json (and a reconstructed stream.jsonl) to the
     normal cell directory unless one already exists.
"""
from __future__ import annotations

import argparse
import json
import sqlite3
import sys
import time
from collections import Counter
from pathlib import Path

SCRIPTS = Path(__file__).resolve().parent
REPO_ROOT = SCRIPTS.parent.parent

# Same helpers the runner uses.
sys.path.insert(0, str(REPO_ROOT / "final-artifacts" / "scripts"))
sys.path.insert(0, str(SCRIPTS))
from unified_harness import (  # noqa: E402
    extract_sympy_blocks, verify_sympy_block,
    has_bare_sorry, parse_diagnostics, SYMPY_SKILL_BLOCK,
)
from opencode_runner import (  # noqa: E402
    EVAL_DIR, FALLBACK_LEAN_BLOCK_RE, FINAL_BLOCK_RE,
    cell_dir, extract_final_proof, lean_compile_local, safe_slot,
)

DB_PATH = Path.home() / ".local" / "share" / "opencode" / "opencode.db"
DEFAULT_MANIFEST = (REPO_ROOT / "final-report" / "data" / "eval_snapshots"
                    / "20260510_083526_partial" / "manifest.json")


def load_manifest_signatures(manifest_path: Path) -> dict[str, dict]:
    """Map verified_signature → problem record. Used to identify (pid) by prompt."""
    m = json.loads(manifest_path.read_text(encoding="utf-8"))
    out: dict[str, dict] = {}
    for p in m["problems"]:
        sig = p["verified_signature"]
        out[sig.strip()] = p
    return out


def first_user_model(con: sqlite3.Connection, sid: str) -> tuple[str, str] | None:
    """Return (providerID, modelID) of the first user message, or None."""
    row = con.execute(
        "SELECT data FROM message WHERE session_id=? AND data LIKE '%\"role\":\"user\"%' "
        "ORDER BY time_created LIMIT 1", (sid,),
    ).fetchone()
    if not row:
        return None
    try:
        d = json.loads(row[0])
        m = d.get("model") or {}
        if m.get("providerID") and m.get("modelID"):
            return m["providerID"], m["modelID"]
    except json.JSONDecodeError:
        pass
    return None


def first_prompt_text(con: sqlite3.Connection, sid: str) -> str:
    """Return the first text part body (which IS the prompt)."""
    row = con.execute(
        "SELECT data FROM part WHERE session_id=? AND data LIKE '%\"type\":\"text\"%' "
        "ORDER BY time_created LIMIT 1", (sid,),
    ).fetchone()
    if not row:
        return ""
    try:
        d = json.loads(row[0])
        # Drop outer surrounding quotes if present (opencode wraps prompt in JSON-string)
        return d.get("text", "")
    except json.JSONDecodeError:
        return ""


def identify_cell(prompt: str, sigs: dict[str, dict]) -> tuple[dict | None, str | None]:
    """Find the manifest problem whose verified_signature is embedded in the prompt.

    Returns (problem_record, condition) where condition is "lean_only" or "with_sympy".
    """
    # Normalize: opencode wraps the prompt in JSON-string quotes — strip those.
    p = prompt
    if p.startswith('"') and p.endswith('"'):
        try:
            p = json.loads(p)
        except json.JSONDecodeError:
            pass
    if not p:
        return None, None
    cond = "with_sympy" if "SYMPY-SKILL" in p else "lean_only"
    for sig, rec in sigs.items():
        if sig in p:
            return rec, cond
    return None, cond


def replay_session(con: sqlite3.Connection, sid: str) -> dict:
    """Walk the part stream and reproduce parse_stream's outputs."""
    rows = con.execute(
        "SELECT data, time_created FROM part WHERE session_id=? ORDER BY time_created",
        (sid,),
    ).fetchall()
    if not rows:
        return {}
    t_start = rows[0][1]
    t_end = rows[-1][1]
    mcp_calls = 0
    budget_hit_event = False
    final_text_parts: list[str] = []
    last_compiled_code: str | None = None
    last_submitted_code: str | None = None
    total_cost = 0.0
    total_tokens = 0
    user_text_seen = False
    submissions: list[str] = []
    for raw, _ in rows:
        try:
            d = json.loads(raw)
        except json.JSONDecodeError:
            continue
        t = d.get("type")
        if t == "text":
            text = d.get("text", "") or ""
            # The first text part is the user prompt; subsequent are model text.
            if not user_text_seen:
                user_text_seen = True
                continue
            final_text_parts.append(text)
        elif t == "tool":
            tool_name = d.get("tool", "") or ""
            if "lean-checker" in tool_name or "check_lean_proof" in tool_name:
                mcp_calls += 1
                state = d.get("state", {}) or {}
                inp = state.get("input", {}) or {}
                code = inp.get("code") if isinstance(inp, dict) else None
                if code:
                    last_submitted_code = code
                    submissions.append(code)
                output = state.get("output", "") or ""
                if "BUDGET_EXHAUSTED" in output:
                    budget_hit_event = True
                else:
                    try:
                        out_obj = json.loads(output) if output else {}
                        if (isinstance(out_obj, dict)
                                and out_obj.get("success") is True
                                and code):
                            last_compiled_code = code
                    except json.JSONDecodeError:
                        pass
        elif t == "step-finish":
            cost = d.get("cost") or 0
            if isinstance(cost, (int, float)):
                total_cost += cost
            tok = d.get("tokens") or {}
            if isinstance(tok, dict):
                total_tokens += int(tok.get("total") or 0)
    return {
        "mcp_calls": mcp_calls,
        "budget_hit_event": budget_hit_event,
        "final_text": "\n".join(final_text_parts),
        "last_compiled_code": last_compiled_code,
        "last_submitted_code": last_submitted_code,
        "total_cost_usd": round(total_cost, 6),
        "total_tokens": total_tokens,
        "wall_seconds": round((t_end - t_start) / 1000.0, 2),
    }


def reconstruct_stream_jsonl(con: sqlite3.Connection, sid: str) -> str:
    """Best-effort rebuild of stream.jsonl in opencode-run --format json shape.

    We translate DB part types -> stream event types so the existing parser
    in opencode_runner.parse_stream would still produce the same numbers.
    """
    rows = con.execute(
        "SELECT id, data, time_created FROM part WHERE session_id=? ORDER BY time_created",
        (sid,),
    ).fetchall()
    out = []
    for pid, raw, t in rows:
        try:
            part = json.loads(raw)
        except json.JSONDecodeError:
            continue
        ty = part.get("type", "")
        # DB shape -> stream shape
        if ty == "tool":
            stream_ev = {"type": "tool_use", "timestamp": t,
                          "sessionID": sid, "part": {**part, "id": pid}}
        elif ty == "step-start":
            stream_ev = {"type": "step_start", "timestamp": t,
                          "sessionID": sid, "part": {**part, "id": pid}}
        elif ty == "step-finish":
            stream_ev = {"type": "step_finish", "timestamp": t,
                          "sessionID": sid, "part": {**part, "id": pid}}
        elif ty == "text":
            stream_ev = {"type": "text", "timestamp": t,
                          "sessionID": sid, "part": {**part, "id": pid}}
        else:
            stream_ev = {"type": ty, "timestamp": t,
                          "sessionID": sid, "part": {**part, "id": pid}}
        out.append(json.dumps(stream_ev, ensure_ascii=False))
    return "\n".join(out) + "\n"


def make_outcome_record(model: str, condition: str, pid: str,
                        parsed: dict, prompt: str) -> dict:
    """Apply the same outcome ladder opencode_runner uses. Re-compile the
    final proof to get a faithful pass/fail tag."""
    # Final proof extraction: explicit > last_compiled > loose lean block > last_submitted.
    final_text = parsed["final_text"]
    final_code = extract_final_proof(final_text)
    final_source = "explicit_block" if final_code else None
    if not final_code and parsed.get("last_compiled_code"):
        final_code = parsed["last_compiled_code"]
        final_source = "last_compiled_tool_call"
    if not final_code:
        m = FALLBACK_LEAN_BLOCK_RE.search(final_text or "")
        if m:
            final_code = m.group(1).strip()
            final_source = "loose_lean_block"
    if not final_code and parsed.get("last_submitted_code"):
        final_code = parsed["last_submitted_code"]
        final_source = "last_submitted_tool_call"
    if final_code and not final_code.lstrip().startswith("import"):
        final_code = "import Mathlib\n\n" + final_code.lstrip()

    slot = safe_slot(pid, model, condition)
    if final_code:
        comp = lean_compile_local(final_code, slot)
    else:
        comp = {"success": False, "exit_code": -3,
                "diagnostics": [], "errors_only": []}

    sympy_blocks = extract_sympy_blocks(final_text)
    sympy_witnesses = [
        {"block": b, "verifier": verify_sympy_block(b)} for b in sympy_blocks
    ]
    sympy_emitted = bool(sympy_blocks)
    sympy_ok = any(w["verifier"].get("correct") for w in sympy_witnesses)

    sf = has_bare_sorry(final_code or "")
    has_sorry_like = sf["any"]
    lean_ok = comp["success"]

    # Outcome ladder: same as opencode_runner.run_cell.
    if final_code is None:
        outcome = "no_final_proof"
    elif lean_ok and not has_sorry_like:
        outcome = "lean_proof"
    elif has_sorry_like and sympy_ok:
        outcome = "sympy_rescue"
    elif has_sorry_like:
        outcome = "instruction_violation"
    else:
        outcome = "compile_fail"

    return {
        "problem_id": pid,
        "model": model,
        "condition": condition,
        "outcome": outcome,
        "overall_success": outcome in ("lean_proof", "sympy_rescue"),
        "wall_seconds": parsed["wall_seconds"],
        "wall_exceeded": False,  # we can't tell from DB alone; mark False
        "final_proof_source": final_source,
        "mcp_calls": parsed["mcp_calls"],
        "budget": 10,  # all our DeepSeek runs used budget=10
        "budget_hit_event": parsed["budget_hit_event"],
        "lean_compiles_raw": lean_ok,
        "has_bare_sorry": sf["sorry"],
        "has_admit": sf["admit"],
        "has_axiom": sf["axiom"],
        "instruction_violation": outcome == "instruction_violation",
        "sympy_emitted": sympy_emitted,
        "sympy_verified": sympy_ok,
        "n_errors": len(comp["errors_only"]),
        "first_error": (comp["errors_only"][0]["message"][:200]
                        if comp["errors_only"] else None),
        "total_cost_usd": parsed["total_cost_usd"],
        "total_tokens": parsed["total_tokens"],
        "sympy_witnesses": sympy_witnesses,
        "errors_only": comp["errors_only"],
        "_recovered_from_db": True,
    }


def main() -> None:
    ap = argparse.ArgumentParser()
    ap.add_argument("--db", default=str(DB_PATH))
    ap.add_argument("--manifest", default=str(DEFAULT_MANIFEST))
    ap.add_argument("--filter-providers", nargs="+", default=["deepseek"])
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--overwrite", action="store_true",
                    help="Overwrite outcome.json if cell already exists")
    args = ap.parse_args()

    sigs = load_manifest_signatures(Path(args.manifest))
    print(f"Loaded {len(sigs)} manifest signatures.")

    con = sqlite3.connect(f"file:{args.db}?mode=ro", uri=True)
    sessions = [r[0] for r in con.execute("SELECT id FROM session")]
    print(f"Total sessions in DB: {len(sessions)}")

    matched = 0
    written = 0
    skipped_existing = 0
    skipped_unmatched = 0
    skipped_wrong_provider = 0
    skipped_broken_wal = 0
    by_outcome = Counter()

    # First pass: collect candidate sessions per (model, cond, pid) cell.
    candidates: dict[tuple[str, str, str], list[tuple[str, dict]]] = {}
    for sid in sessions:
        m = first_user_model(con, sid)
        if not m:
            continue
        provider, model_id = m
        if provider not in args.filter_providers:
            skipped_wrong_provider += 1
            continue
        prompt = first_prompt_text(con, sid)
        rec, cond = identify_cell(prompt, sigs)
        if not rec or not cond:
            skipped_unmatched += 1
            continue
        matched += 1
        parsed = replay_session(con, sid)
        if not parsed:
            continue
        # Filter out broken-WAL sessions (returned in <5s with no real work).
        if parsed["wall_seconds"] < 5 and parsed["mcp_calls"] == 0:
            skipped_broken_wal += 1
            continue
        key = (model_id, cond, rec["problem_id"])
        candidates.setdefault(key, []).append((sid, parsed, prompt))

    # Second pass: for each cell, pick best session (max wall, then max mcp_calls).
    print(f"\nDistinct cells with at least one candidate session: {len(candidates)}\n")
    for (model_id, cond, pid), cands in candidates.items():
        cdir = cell_dir(model_id, cond, pid)
        outcome_path = cdir / "outcome.json"
        if outcome_path.exists() and not args.overwrite:
            skipped_existing += 1
            continue
        # Pick best: maximize (wall, mcp_calls).
        best_sid, parsed, prompt = max(
            cands, key=lambda c: (c[1]["wall_seconds"], c[1]["mcp_calls"]),
        )
        record = make_outcome_record(model_id, cond, pid, parsed, prompt)
        by_outcome[record["outcome"]] += 1

        if args.dry_run:
            print(f"  WOULD WRITE {model_id}/{cond}/{pid}: "
                  f"{record['outcome']}  wall={record['wall_seconds']}s "
                  f"mcp={record['mcp_calls']}  cost=${record['total_cost_usd']}")
            continue

        cdir.mkdir(parents=True, exist_ok=True)
        # Write reconstructed stream.jsonl + outcome.json + final.lean.
        stream_text = reconstruct_stream_jsonl(con, best_sid)
        (cdir / "stream.jsonl").write_text(stream_text, encoding="utf-8")
        (cdir / "final_text.txt").write_text(parsed["final_text"], encoding="utf-8")
        (cdir / "prompt.txt").write_text(prompt, encoding="utf-8")
        # Re-derive final_code identical to make_outcome_record above.
        final_code = extract_final_proof(parsed["final_text"])
        if not final_code and parsed.get("last_compiled_code"):
            final_code = parsed["last_compiled_code"]
        if not final_code:
            mm = FALLBACK_LEAN_BLOCK_RE.search(parsed["final_text"] or "")
            if mm:
                final_code = mm.group(1).strip()
        if not final_code and parsed.get("last_submitted_code"):
            final_code = parsed["last_submitted_code"]
        if final_code and not final_code.lstrip().startswith("import"):
            final_code = "import Mathlib\n\n" + final_code.lstrip()
        if final_code:
            (cdir / "final.lean").write_text(final_code, encoding="utf-8")
        outcome_path.write_text(
            json.dumps(record, indent=2, ensure_ascii=False), encoding="utf-8",
        )
        written += 1
        print(f"  wrote {model_id:<22s}/{cond:<12s}/{pid:<32s} "
              f"{record['outcome']:<22s}  wall={record['wall_seconds']:>6}s "
              f"mcp={record['mcp_calls']:>2d}  cost=${record['total_cost_usd']:.4f}")

    con.close()
    print(f"\n=== Summary ===")
    print(f"  matched (provider+manifest sig): {matched}")
    print(f"  written outcome.json:            {written}")
    print(f"  skipped (already exist):         {skipped_existing}")
    print(f"  skipped (no manifest match):     {skipped_unmatched}")
    print(f"  skipped (wrong provider):        {skipped_wrong_provider}")
    if by_outcome:
        print(f"\nOutcome distribution of recovered cells:")
        for k, v in sorted(by_outcome.items(), key=lambda x: -x[1]):
            print(f"  {k:<22s} {v}")


if __name__ == "__main__":
    main()
