"""
Phase 2 overnight runner — orchestrator for the multi-model prover leaderboard.

Five stages: preflight → smoke → main matrix → hub-recall → aggregate → morning_summary.
Fully autonomous: when something unexpected happens, consult gpt-5.5 (codex-judge)
and follow its recommendation. Never pause for user.

Build incrementally per /home/node/.claude/plans/dynamic-watching-wall.md.
"""

from __future__ import annotations

import argparse
import datetime as _dt
import json
import os
import random
import shutil
import sys
import time
from collections import Counter
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
from unified_harness import (  # noqa: E402
    ALL_MODELS,
    DEEPSEEK_KEY_FILE,
    NO_TOOLS_PREAMBLE,
    PROMPT_INITIAL,
    PROMPT_RETRY,
    SYMPY_SKILL_BLOCK,
    codex_call,
    extract_sympy_blocks,
    has_bare_sorry,
    lean_compile,
    run_attempt,
    strip_codeblock,
    verify_sympy_block,
)


# ============================== Paths ==============================

REPO_ROOT = Path("/workspace")
FINAL_REPORT = REPO_ROOT / "final-report"
DATASET_ROOT = REPO_ROOT / "final-presentation" / "d2_curation_v2" / "data"
NODES_DIR = DATASET_ROOT / "dataset_v2" / "nodes"
EDGES_FILE = DATASET_ROOT / "dataset_v2" / "edges.json"
FORMALIZATIONS_DIR = DATASET_ROOT / "formalizations"

AUDIT_FILE = FINAL_REPORT / "data" / "phase1_smoke" / "formalization_audit.json"
TONIGHT5_FILE = FINAL_REPORT / "data" / "phase1_smoke" / "tonight_5.json"

EVAL_DIR = FINAL_REPORT / "data" / "eval_overnight"
MANIFEST_FILE = EVAL_DIR / "manifest.json"
PREFLIGHT_FILE = EVAL_DIR / "preflight.json"
DECISION_LOG = EVAL_DIR / "decision_log.jsonl"
CHECKPOINT_DIR = EVAL_DIR / "checkpoints"


# ============================== Defaults ==============================

DEFAULT_MODELS = [
    "gpt-5.5",
    "gpt-5.4-mini",
    "claude-opus-4-7",
    "deepseek-v4-pro",
    "deepseek-v4-flash",
]

DEFAULT_K = 3
DEFAULT_CONDITIONS = ["lean_only", "with_sympy"]
DEFAULT_MAX_WORKERS = 4
DEFAULT_CHECKPOINT_EVERY = 5
DEFAULT_N_PROBLEMS = 30
DEFAULT_SEED = 42
DEFAULT_TIMEOUT = 240


# ============================== Step 2.1: Sampler ==============================


def _now_iso() -> str:
    return _dt.datetime.now().isoformat(timespec="seconds")


def _load_hubs_and_gt() -> tuple[set[str], dict[str, list[str]]]:
    """Return (hub_ids, problem_id -> sorted list of hub_ids that connect)."""
    hub_ids: set[str] = set()
    for f in NODES_DIR.glob("*-hub.json"):
        n = json.loads(f.read_text())
        if n.get("type") == "hub":
            hub_ids.add(n["id"])
    edges = json.loads(EDGES_FILE.read_text())
    gt: dict[str, set[str]] = {}
    for e in edges:
        a, b = e["a"], e["b"]
        if a in hub_ids and b not in hub_ids:
            gt.setdefault(b, set()).add(a)
        elif b in hub_ids and a not in hub_ids:
            gt.setdefault(a, set()).add(b)
    return hub_ids, {k: sorted(v) for k, v in gt.items()}


def _faithful_pool() -> list[dict]:
    """Load the FAITHFUL pool from the existing audit. Returns audit-row dicts."""
    audit = json.loads(AUDIT_FILE.read_text())
    return [r for r in audit if r.get("verdict") == "FAITHFUL"]


def _final_code_for(pid: str) -> str | None:
    """Read Stage-7 final_code for a problem_id (preferred over audit's lean_code)."""
    sp = FORMALIZATIONS_DIR / pid / "summary.json"
    if not sp.exists():
        return None
    s = json.loads(sp.read_text())
    fc = s.get("final_code")
    if not fc:
        return None
    fc = fc.rstrip()
    return fc if fc.endswith(":= by\n  sorry") or fc.endswith(":= by sorry") else None


def _build_problem_entry(pid: str, statement_en: str, signature: str,
                          difficulty: str | None, problem_type: str | None,
                          domain: str | None, pinned: bool, kind: str | None,
                          gt: dict[str, list[str]]) -> dict:
    return {
        "problem_id": pid,
        "statement_en": statement_en,
        "verified_signature": signature,
        "difficulty": difficulty,
        "problem_type": problem_type,
        "domain": domain,
        "pinned": pinned,
        "kind": kind,  # "pure" | "computational" | None
        "ground_truth_hubs": gt.get(pid, []),
    }


def sample_problems(n: int = DEFAULT_N_PROBLEMS, seed: int = DEFAULT_SEED) -> list[dict]:
    """Sample n problems: pin tonight_5 + 3 cherry-picks, sample remainder stratified."""
    _, gt = _load_hubs_and_gt()
    audit_pool = _faithful_pool()
    audit_by_id = {r["problem_id"]: r for r in audit_pool}

    # ---- Pin tonight_5 (5 entries) ----
    t5 = json.loads(TONIGHT5_FILE.read_text())
    pinned: list[dict] = []
    pinned_ids: set[str] = set()
    for p in t5:
        pid = p["problem_id"]
        # tonight_5 entries always carry a verified_signature; trust it.
        # Pull difficulty/problem_type/domain from audit if we have them.
        ax = audit_by_id.get(pid, {})
        pinned.append(_build_problem_entry(
            pid=pid,
            statement_en=p["statement_en"],
            signature=p["verified_signature"],
            difficulty=ax.get("difficulty"),
            problem_type=ax.get("problem_type"),
            domain=ax.get("domain"),
            pinned=True,
            kind=p.get("kind"),
            gt=gt,
        ))
        pinned_ids.add(pid)

    # ---- 3 cherry-picks for narrative variety (FAITHFUL only) ----
    rem = [r for r in audit_pool if r["problem_id"] not in pinned_ids]
    rng = random.Random(seed)

    def _first_match(predicate):
        cands = [r for r in rem if predicate(r)]
        rng.shuffle(cands)
        return cands[0] if cands else None

    cherry: list[dict] = []
    # (a) easy theorem
    e_thm = _first_match(lambda r: r.get("difficulty") == "easy" and r.get("problem_type") == "theorem")
    # (b) medium/hard lemma
    h_lem = _first_match(lambda r: r.get("problem_type") == "lemma" and r.get("difficulty") in ("medium", "hard"))
    # (c) computational/measure-theory exercise (proxy for "third axis")
    cmp_ex = _first_match(lambda r: r.get("problem_type") == "exercise" and r.get("domain") in
                                    {"measure theory", "real analysis", "complex analysis", "harmonic analysis"})
    for ax in [e_thm, h_lem, cmp_ex]:
        if ax is None:
            continue
        pid = ax["problem_id"]
        sig = _final_code_for(pid) or ax.get("lean_code")
        if not sig:
            continue
        cherry.append(_build_problem_entry(
            pid=pid,
            statement_en=ax.get("statement_en", ""),
            signature=sig,
            difficulty=ax.get("difficulty"),
            problem_type=ax.get("problem_type"),
            domain=ax.get("domain"),
            pinned=True,
            kind=None,
            gt=gt,
        ))
        pinned_ids.add(pid)

    # ---- Remaining slots: stratified random ----
    n_remaining = n - len(pinned) - len(cherry)
    rem = [r for r in audit_pool if r["problem_id"] not in pinned_ids]

    # Stratify by (difficulty, problem_type) bucket; sample proportionally
    def _bucket(r):
        return (r.get("difficulty") or "?", r.get("problem_type") or "?")

    by_bucket: dict[tuple, list[dict]] = {}
    for r in rem:
        by_bucket.setdefault(_bucket(r), []).append(r)
    # Shuffle within each bucket for determinism
    for b in by_bucket.values():
        rng.shuffle(b)

    # Round-robin draw across buckets weighted by bucket size, until n_remaining filled
    sample: list[dict] = []
    bucket_keys = sorted(by_bucket.keys())
    while len(sample) < n_remaining and any(by_bucket.values()):
        for k in bucket_keys:
            if not by_bucket[k]:
                continue
            ax = by_bucket[k].pop()
            pid = ax["problem_id"]
            sig = _final_code_for(pid) or ax.get("lean_code")
            if not sig:
                continue
            sample.append(_build_problem_entry(
                pid=pid,
                statement_en=ax.get("statement_en", ""),
                signature=sig,
                difficulty=ax.get("difficulty"),
                problem_type=ax.get("problem_type"),
                domain=ax.get("domain"),
                pinned=False,
                kind=None,
                gt=gt,
            ))
            if len(sample) >= n_remaining:
                break

    return pinned + cherry + sample


def write_manifest(out_path: Path = MANIFEST_FILE,
                   n: int = DEFAULT_N_PROBLEMS, seed: int = DEFAULT_SEED) -> dict:
    """Build & freeze the manifest."""
    out_path.parent.mkdir(parents=True, exist_ok=True)
    problems = sample_problems(n=n, seed=seed)
    manifest = {
        "timestamp": _now_iso(),
        "seed": seed,
        "models": DEFAULT_MODELS,
        "K": DEFAULT_K,
        "fast_fail_on_attempt_1_timeout": True,
        "conditions": DEFAULT_CONDITIONS,
        "max_workers_initial": DEFAULT_MAX_WORKERS,
        "checkpoint_every": DEFAULT_CHECKPOINT_EVERY,
        "timeout_per_attempt": DEFAULT_TIMEOUT,
        "n_problems": len(problems),
        "problems": problems,
    }
    out_path.write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding="utf-8")
    return manifest


# ============================== CLI ==============================


# ============================== Step 2.2: Pre-flight ==============================


def preflight() -> dict:
    """Verify infra before any work. Returns dict; raises SystemExit on hard fail."""
    EVAL_DIR.mkdir(parents=True, exist_ok=True)
    result: dict = {"timestamp": _now_iso(), "checks": {}, "ok": True}

    # 1. PONG-ping all 5 models
    pongs: dict = {}
    for m in DEFAULT_MODELS:
        t0 = time.time()
        r = run_attempt(m, "Reply with exactly: PONG")
        text = (r.get("response_text") or "").upper()
        ok = "PONG" in text
        pongs[m] = {"ok": ok, "wall": round(time.time() - t0, 1),
                    "response_excerpt": (r.get("response_text") or "")[:60]}
        if not ok:
            result["ok"] = False
    result["checks"]["pong"] = pongs

    # 2. Lake project healthcheck
    t0 = time.time()
    cr = lean_compile("import Mathlib\n\nexample : True := trivial\n", "_overnight_preflight")
    lake_ok = bool(cr.get("success"))
    result["checks"]["lake_compile"] = {"ok": lake_ok, "wall": round(time.time() - t0, 1),
                                          "n_errors": len(cr.get("errors_only", []))}
    if not lake_ok:
        result["ok"] = False

    # 3. DeepSeek key file
    ds_ok = DEEPSEEK_KEY_FILE.exists() and len(DEEPSEEK_KEY_FILE.read_text().strip()) > 0
    result["checks"]["deepseek_key"] = {"ok": ds_ok, "path": str(DEEPSEEK_KEY_FILE)}
    if not ds_ok:
        result["ok"] = False

    # 4. Disk free in EVAL_DIR (≥ 500 MB)
    du = shutil.disk_usage(str(EVAL_DIR))
    free_mb = du.free // (1024 * 1024)
    disk_ok = free_mb >= 500
    result["checks"]["disk_free_mb"] = {"ok": disk_ok, "free_mb": free_mb}
    if not disk_ok:
        result["ok"] = False

    # 5. Manifest exists & has problems
    if MANIFEST_FILE.exists():
        try:
            m = json.loads(MANIFEST_FILE.read_text())
            mfok = len(m.get("problems", [])) > 0
            result["checks"]["manifest"] = {"ok": mfok, "n_problems": len(m.get("problems", []))}
            if not mfok:
                result["ok"] = False
        except Exception as e:
            result["checks"]["manifest"] = {"ok": False, "error": str(e)}
            result["ok"] = False
    else:
        result["checks"]["manifest"] = {"ok": False, "error": "manifest.json missing"}
        result["ok"] = False

    PREFLIGHT_FILE.write_text(json.dumps(result, indent=2, ensure_ascii=False), encoding="utf-8")
    return result


# ============================== Step 2.4: Codex-judge ==============================


JUDGE_PROMPT = """You are an autonomous-runner debugger. The runner is mid-experiment and
encountered an unexpected condition. Pick exactly one action.

SITUATION: {situation}

CONTEXT (truncated to 1500 chars):
{context_json}

RECENT HISTORY (last 5 events):
{history_json}

Available actions (output exactly one as a single-line JSON object):
  {{"action": "retry", "reason": "..."}}                                # try same call once more
  {{"action": "skip_cell", "reason": "..."}}                            # mark cell failed, move on
  {{"action": "skip_model", "reason": "..."}}                           # drop this model from remaining work
  {{"action": "throttle", "reason": "...", "params": {{"workers": <int 1-6>, "sleep_seconds": <int 0-300>}}}}
  {{"action": "patch_param", "reason": "...", "params": {{"timeout": <int 60-600>}}}}
  {{"action": "escalate_log", "reason": "..."}}                         # log at top severity, continue

Output ONLY one JSON object on a single line. No markdown, no commentary."""


_VALID_ACTIONS = {"retry", "skip_cell", "skip_model", "throttle", "patch_param", "escalate_log"}


def consult_codex_judge(situation: str, context: dict, history: list) -> dict:
    """Call codex (gpt-5.5) to recommend an action. Falls back to default on garbage."""
    try:
        prompt = JUDGE_PROMPT.format(
            situation=situation,
            context_json=json.dumps(context, default=str)[:1500],
            history_json=json.dumps(history[-5:], default=str)[:800],
        )
        text, meta = codex_call("gpt-5.5", prompt, timeout=120)
        if not text:
            return {"action": "escalate_log", "reason": "judge_no_response", "params": {},
                    "judge_raw": "", "judge_wall": meta.get("wall_seconds")}
        # Find first JSON object
        import re as _re
        m = _re.search(r"\{.*?\}", text, _re.DOTALL)
        if not m:
            return {"action": "escalate_log", "reason": "judge_no_json",
                    "params": {}, "judge_raw": text[:300]}
        d = json.loads(m.group(0))
        action = d.get("action")
        if action not in _VALID_ACTIONS:
            return {"action": "escalate_log", "reason": f"judge_invalid_action: {action}",
                    "params": {}, "judge_raw": text[:300]}
        return {"action": action, "reason": d.get("reason", ""), "params": d.get("params", {}),
                "judge_raw": text[:300], "judge_wall": meta.get("wall_seconds")}
    except Exception as e:
        return {"action": "escalate_log", "reason": f"judge_exception: {type(e).__name__}: {e}",
                "params": {}, "judge_raw": ""}


def append_decision(entry: dict) -> None:
    DECISION_LOG.parent.mkdir(parents=True, exist_ok=True)
    entry = {"timestamp": _now_iso(), **entry}
    with DECISION_LOG.open("a", encoding="utf-8") as f:
        f.write(json.dumps(entry, ensure_ascii=False) + "\n")


# ============================== Step 2.3: Cell runner ==============================


def _safe_slot(pid: str, model: str, condition: str) -> str:
    import hashlib
    return "P2_" + hashlib.md5(f"{pid}|{model}|{condition}".encode()).hexdigest()[:10]


def _format_diags_for_prompt(diags: list[dict]) -> str:
    if not diags:
        return "(no diagnostics returned)"
    return "\n".join(
        f"line {d.get('line')}:{d.get('column')}: {d.get('severity')}: {(d.get('message') or '')[:300]}"
        for d in diags[:8]
    )


def evaluate_attempt(code: str, slot: str, response_text: str) -> dict:
    """Outcome ladder. Mirrors phase1_calibration.evaluate_attempt + adds model_timeout (set externally)."""
    compile_result = lean_compile(code, slot)
    n_errors = len(compile_result.get("errors_only", []))
    first_err = (compile_result["errors_only"][0]["message"][:200]
                 if compile_result.get("errors_only") else None)

    sympy_blocks = extract_sympy_blocks(response_text)
    sympy_witnesses = []
    for b in sympy_blocks:
        v = verify_sympy_block(b)
        sympy_witnesses.append({"block": b, "verifier": v})
    sympy_emitted = len(sympy_blocks) > 0
    sympy_ok = any(w["verifier"].get("correct") for w in sympy_witnesses)

    sf = has_bare_sorry(code)
    has_sorry_like = sf["any"]
    lean_ok = compile_result["success"]

    if lean_ok and not has_sorry_like:
        outcome = "lean_proof"
    elif has_sorry_like and sympy_ok:
        outcome = "sympy_rescue"
    elif has_sorry_like:
        outcome = "instruction_violation"
    else:
        outcome = "compile_fail"

    return {
        "outcome": outcome,
        "overall_success": outcome in ("lean_proof", "sympy_rescue"),
        "lean_compiles_raw": lean_ok,
        "has_bare_sorry": sf["sorry"], "has_admit": sf["admit"], "has_axiom": sf["axiom"],
        "instruction_violation": outcome == "instruction_violation",
        "sympy_emitted": sympy_emitted, "sympy_verified": sympy_ok,
        "n_errors": n_errors, "first_error": first_err,
        "sympy_witnesses": sympy_witnesses,
        "errors_only": compile_result.get("errors_only", []),
    }


def run_cell(pick: dict, model: str, condition: str, K: int = DEFAULT_K,
              fast_fail: bool = True, out_root: Path | None = None,
              timeout: int = DEFAULT_TIMEOUT) -> dict:
    """Run one (problem, model, condition) cell with K retries."""
    pid = pick["problem_id"]
    statement_en = pick["statement_en"]
    signature_block = pick["verified_signature"]
    sympy_skill = SYMPY_SKILL_BLOCK if condition == "with_sympy" else ""
    slot = _safe_slot(pid, model, condition)
    out_root = out_root or (EVAL_DIR / "stage2_main")
    cell_dir = out_root / model.replace("/", "_") / condition / pid
    cell_dir.mkdir(parents=True, exist_ok=True)

    attempts: list[dict] = []
    last_code = None
    last_errors: list[dict] | None = None
    overall = False
    why = None
    any_timeout = False
    t0 = time.time()

    for k in range(1, K + 1):
        if k == 1:
            prompt = PROMPT_INITIAL.format(
                statement_en=statement_en, signature_block=signature_block,
                no_tools_preamble=NO_TOOLS_PREAMBLE, sympy_skill=sympy_skill,
            )
        else:
            prompt = PROMPT_RETRY.format(
                prev_code=last_code, diagnostics=_format_diags_for_prompt(last_errors or []),
                no_tools_preamble=NO_TOOLS_PREAMBLE, sympy_skill=sympy_skill,
            )

        result = run_attempt(model, prompt, timeout=timeout)
        if result.get("timed_out"):
            any_timeout = True
            attempts.append({"attempt": k, "model_timeout": True,
                             "wall_seconds": result.get("wall_seconds"),
                             "outcome": "model_timeout", "overall_success": False})
            if fast_fail and k == 1:
                why = "model_timeout"
                break
            continue

        if not result.get("ok") or not result.get("response_text"):
            attempts.append({"attempt": k, "model_failed": True,
                             "error": result.get("error"),
                             "wall_seconds": result.get("wall_seconds"),
                             "outcome": "model_failed", "overall_success": False})
            continue

        text = result["response_text"]
        code = strip_codeblock(text)
        if not code.lstrip().startswith("import"):
            code = "import Mathlib\n\n" + code.lstrip()

        (cell_dir / f"attempt_{k}.lean").write_text(code, encoding="utf-8")
        (cell_dir / f"attempt_{k}_raw.txt").write_text(text, encoding="utf-8")

        ev = evaluate_attempt(code, slot, text)
        (cell_dir / f"attempt_{k}_eval.json").write_text(
            json.dumps(ev, indent=2, ensure_ascii=False), encoding="utf-8"
        )
        attempts.append({
            "attempt": k, "wall_seconds": result.get("wall_seconds"),
            **{key: ev[key] for key in ["outcome", "overall_success", "lean_compiles_raw",
                                         "has_bare_sorry", "has_admit", "has_axiom",
                                         "instruction_violation", "sympy_emitted",
                                         "sympy_verified", "n_errors", "first_error"]},
        })
        last_code = code
        last_errors = ev["errors_only"]
        if ev["overall_success"]:
            overall = True
            why = ev["outcome"]
            break

    summary = {
        "problem_id": pid, "model": model, "condition": condition, "K": K,
        "overall_success": overall, "why_success": why,
        "attempts_used": len(attempts), "any_timeout": any_timeout,
        "wall_seconds": round(time.time() - t0, 1),
        "attempts": attempts,
    }
    (cell_dir / "summary.json").write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8")
    return summary


def safe_run_cell(pick: dict, model: str, condition: str, K: int = DEFAULT_K,
                   fast_fail: bool = True, out_root: Path | None = None,
                   timeout: int = DEFAULT_TIMEOUT, history: list | None = None) -> dict:
    """Cell runner with codex-judge fault tolerance."""
    history = history if history is not None else []
    try:
        return run_cell(pick, model, condition, K=K, fast_fail=fast_fail,
                        out_root=out_root, timeout=timeout)
    except Exception as e:
        ctx = {"problem_id": pick.get("problem_id"), "model": model, "condition": condition,
               "exception": f"{type(e).__name__}: {e}"}
        decision = consult_codex_judge(situation="cell_runner_exception", context=ctx, history=history)
        append_decision({"situation": "cell_runner_exception", "context": ctx,
                          "decision": decision})
        # Honor decision
        if decision["action"] == "retry":
            try:
                return run_cell(pick, model, condition, K=K, fast_fail=fast_fail,
                                out_root=out_root, timeout=timeout)
            except Exception as e2:
                append_decision({"situation": "retry_after_judge_failed",
                                  "context": {**ctx, "exception_2": str(e2)},
                                  "decision": {"action": "skip_cell", "reason": "retry also failed"}})
        # skip_cell, skip_model, throttle, patch_param, escalate_log → return a sentinel cell
        return {
            "problem_id": pick.get("problem_id"), "model": model, "condition": condition,
            "K": K, "overall_success": False, "why_success": None,
            "attempts_used": 0, "any_timeout": False, "wall_seconds": 0.0,
            "attempts": [],
            "codex_judge_action": decision["action"],
            "codex_judge_reason": decision.get("reason"),
            "exception": ctx["exception"],
        }


# ============================== Step 2.5: WorkerScaler ==============================


class WorkerScaler:
    def __init__(self, initial: int = DEFAULT_MAX_WORKERS, min_w: int = 1, max_w: int = 6):
        self.workers = initial
        self.min_w = min_w
        self.max_w = max_w
        self.last_change_t = time.time()

    def reconsider(self, recent_cells: list[dict]) -> int:
        if not recent_cells:
            return self.workers
        timeouts = sum(1 for c in recent_cells if c.get("any_timeout"))
        rate = timeouts / max(1, len(recent_cells))
        if rate > 0.4 and self.workers > self.min_w:
            self.workers -= 1
            self.last_change_t = time.time()
        elif rate < 0.1 and (time.time() - self.last_change_t > 1800) and self.workers < self.max_w:
            self.workers += 1
            self.last_change_t = time.time()
        return self.workers


# ============================== Step 2.6: Stage 1 smoke ==============================


from concurrent.futures import ThreadPoolExecutor, as_completed  # noqa: E402


def run_stage_smoke(manifest: dict, n_problems: int = 5, K: int = 2,
                     max_workers: int = 4) -> dict:
    """Smoke test on n_problems non-pinned (sampled) problems.

    Pinned problems include intentionally-hard pins (e.g., lemma-21, problem-31-3)
    used for capability-decomposition narrative — they are NOT a fair infrastructure
    check. Use sampled-only problems so 0/N truly indicates a broken model, not
    "model is weaker than the strongest on the hardest pin in the set".
    """
    candidates = [p for p in manifest["problems"] if not p.get("pinned")]
    if len(candidates) < n_problems:
        candidates = manifest["problems"]
    problems = candidates[:n_problems]
    print(f"[smoke] Running on {n_problems} non-pinned problems × {len(manifest['models'])} models × K={K}")
    print(f"[smoke] Problems: {[p['problem_id'] for p in problems]}")
    models = list(manifest["models"])
    out_root = EVAL_DIR / "stage1_smoke"

    cells: list[dict] = []
    history: list[dict] = []
    with ThreadPoolExecutor(max_workers=max_workers) as ex:
        futures = {}
        for p in problems:
            for m in models:
                futures[ex.submit(safe_run_cell, p, m, "with_sympy", K, True, out_root,
                                   DEFAULT_TIMEOUT, history)] = (p["problem_id"], m)
        for fut in as_completed(futures):
            pid, m = futures[fut]
            try:
                c = fut.result()
                cells.append(c)
                tag = "✓" if c.get("overall_success") else "✗"
                why = f" via {c.get('why_success')}" if c.get("why_success") else ""
                print(f"  [smoke] [{tag}] {m:<22} {pid:<40} wall={c.get('wall_seconds')}s{why}")
            except Exception as e:
                print(f"  [smoke] [ERR] {m} {pid}: {e}")

    # Per-model success counts
    per_model = {}
    for m in models:
        rs = [c for c in cells if c["model"] == m]
        succ = sum(1 for c in rs if c.get("overall_success"))
        per_model[m] = {"success": succ, "total": len(rs)}

    print()
    print(f"=== SMOKE SUMMARY ===")
    abort = False
    for m, s in per_model.items():
        line = f"  {m:<22} {s['success']}/{s['total']}"
        if s["success"] == 0:
            line += "  ← ABORT trigger"
            abort = True
        print(line)

    summary = {
        "timestamp": _now_iso(), "models": models, "n_problems": n_problems, "K": K,
        "per_model": per_model, "cells": cells, "abort": abort,
    }
    (out_root / "smoke_summary.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return summary


# ============================== Step 2.7: Stage 2 main matrix ==============================


def _completed_cells_for_resume(out_root: Path) -> set[tuple]:
    """Read existing summary.json files; return set of (pid, model, condition)."""
    completed = set()
    if not out_root.exists():
        return completed
    for sp in out_root.glob("*/*/*/summary.json"):
        try:
            s = json.loads(sp.read_text())
            completed.add((s["problem_id"], s["model"], s["condition"]))
        except Exception:
            pass
    return completed


def run_stage_main(manifest: dict, active_models: list[str] | None = None,
                    resume: bool = False, max_workers: int = DEFAULT_MAX_WORKERS,
                    checkpoint_every: int = DEFAULT_CHECKPOINT_EVERY,
                    problems_subset: list[dict] | None = None,
                    K: int = DEFAULT_K) -> dict:
    """Stage 2 main matrix with checkpointing + worker scaling."""
    active_models = active_models or list(manifest["models"])
    problems = problems_subset or manifest["problems"]
    conditions = manifest["conditions"]
    out_root = EVAL_DIR / "stage2_main"
    CHECKPOINT_DIR.mkdir(parents=True, exist_ok=True)

    completed = _completed_cells_for_resume(out_root) if resume else set()
    print(f"[main] Active models: {active_models}")
    print(f"[main] Problems: {len(problems)}  conditions: {conditions}  K={K}")
    print(f"[main] Already completed (resume): {len(completed)} cells")

    todo: list[tuple] = []
    for p in problems:
        for m in active_models:
            for c in conditions:
                if (p["problem_id"], m, c) in completed:
                    continue
                todo.append((p, m, c))
    print(f"[main] Todo: {len(todo)} cells")
    if not todo:
        return {"todo": 0, "cells": []}

    scaler = WorkerScaler(initial=max_workers)
    history: list[dict] = []
    cells: list[dict] = []
    consecutive_failures: dict[str, int] = {m: 0 for m in active_models}
    dropped_models: set[str] = set()
    from collections import deque as _dq
    recent = _dq(maxlen=20)

    # Group todo by problem so we can checkpoint every N problems
    by_problem: dict[str, list[tuple]] = {}
    for t in todo:
        by_problem.setdefault(t[0]["problem_id"], []).append(t)
    problem_order = [p["problem_id"] for p in problems if p["problem_id"] in by_problem]

    processed_problems = 0
    for batch_start in range(0, len(problem_order), checkpoint_every):
        batch_pids = problem_order[batch_start:batch_start + checkpoint_every]
        batch_cells = [t for pid in batch_pids for t in by_problem[pid]
                        if t[1] not in dropped_models]
        if not batch_cells:
            continue
        with ThreadPoolExecutor(max_workers=scaler.workers) as ex:
            futures = {}
            for (p, m, c) in batch_cells:
                futures[ex.submit(safe_run_cell, p, m, c, K, True, out_root,
                                   DEFAULT_TIMEOUT, history)] = (p["problem_id"], m, c)
            for fut in as_completed(futures):
                pid, m, c = futures[fut]
                try:
                    cell = fut.result()
                    cells.append(cell)
                    recent.append(cell)
                    if cell.get("overall_success"):
                        consecutive_failures[m] = 0
                    else:
                        consecutive_failures[m] = consecutive_failures.get(m, 0) + 1
                    tag = "✓" if cell.get("overall_success") else "✗"
                    why = f" via {cell.get('why_success')}" if cell.get("why_success") else ""
                    print(f"  [main] [{tag}] {m:<22} {c:<11} {pid:<40} wall={cell.get('wall_seconds')}s{why}")
                except Exception as e:
                    print(f"  [main] [ERR] {m} {c} {pid}: {e}")

        processed_problems += len(batch_pids)

        # Checkpoint
        cp = {"timestamp": _now_iso(), "processed_problems": processed_problems,
              "n_cells_so_far": len(cells),
              "per_model_success": {m: sum(1 for c in cells if c["model"] == m and c.get("overall_success"))
                                     for m in active_models},
              "active_models": [m for m in active_models if m not in dropped_models],
              "current_workers": scaler.workers,
              }
        cp_file = CHECKPOINT_DIR / f"stage2_after_{processed_problems}_problems.json"
        cp_file.write_text(json.dumps(cp, indent=2, ensure_ascii=False), encoding="utf-8")

        # Adaptive parallelism
        new_workers = scaler.reconsider(list(recent))
        if new_workers != scaler.workers:
            print(f"  [main] WorkerScaler adjusted to {new_workers}")

        # Drop persistently-failing models
        for m in list(active_models):
            if m in dropped_models:
                continue
            if consecutive_failures.get(m, 0) >= 15:
                ctx = {"model": m, "consecutive_failures": consecutive_failures[m],
                        "n_processed": processed_problems}
                decision = consult_codex_judge(situation="model_persistent_failure",
                                                 context=ctx, history=history)
                append_decision({"situation": "model_persistent_failure", "context": ctx,
                                   "decision": decision})
                if decision["action"] in ("skip_model", "escalate_log"):
                    dropped_models.add(m)
                    print(f"  [main] Dropping model {m} (codex: {decision.get('reason')[:80]})")
                else:
                    consecutive_failures[m] = 0  # reset and continue

    return {"timestamp": _now_iso(), "active_models": active_models,
            "dropped_models": sorted(dropped_models), "cells": cells,
            "n_cells": len(cells)}


# ============================== Step 2.8: Stage 3 hub-recall ==============================


HUB_RECALL_PROMPT = """You are given a math problem and a catalog of {n_hubs} strategy hubs.
Each hub represents a recurring proof technique or methodological pattern. Your
task: identify which hub(s) apply to the given problem. Multiple hubs may apply.

PROBLEM STATEMENT:
{statement_en}

HUB CATALOG:
{hub_catalog}

Output ONLY a JSON object on a single line, no markdown, no commentary:
{{"hubs": ["hub-id-1", "hub-id-2", ...], "rationale": "<brief one-sentence justification>"}}

Use the exact hub IDs from the catalog. Empty list `[]` is valid if you believe no hub applies."""


def _load_hub_catalog() -> tuple[list[dict], str]:
    hubs = []
    for f in sorted(NODES_DIR.glob("*-hub.json")):
        n = json.loads(f.read_text())
        if n.get("type") != "hub":
            continue
        strategies = n.get("strategies", [])
        first = strategies[0] if strategies else {}
        hubs.append({
            "id": n["id"],
            "english_title": n.get("english_source_note") or first.get("strategy_name_en", ""),
            "summary": (first.get("summary_en") or "")[:300],
            "applicability": (first.get("applicability") or "")[:200],
        })
    lines = []
    for h in hubs:
        lines.append(f"- {h['id']}")
        lines.append(f"    name: {h['english_title']}")
        if h["summary"]:
            lines.append(f"    summary: {h['summary']}")
        if h["applicability"]:
            lines.append(f"    applies when: {h['applicability']}")
    return hubs, "\n".join(lines)


def _parse_hub_response(text: str) -> dict:
    import re as _re
    if not text:
        return {"hubs": [], "rationale": "empty", "_error": "empty"}
    s = text.strip()
    m = _re.search(r"```(?:json)?\s*\n?(.*?)\n?```", s, _re.DOTALL)
    if m:
        s = m.group(1).strip()
    m = _re.search(r"\{[^{}]*\"hubs\"[^{}]*\}", s, _re.DOTALL)
    if not m:
        m = _re.search(r"\{.*\}", s, _re.DOTALL)
    if not m:
        return {"hubs": [], "rationale": "", "_error": f"no_json: {text[:120]!r}"}
    try:
        d = json.loads(m.group(0))
        return {"hubs": list(d.get("hubs", [])), "rationale": d.get("rationale", "")}
    except Exception as e:
        return {"hubs": [], "rationale": "", "_error": f"parse: {e}"}


def _score_hub(predicted: list[str], ground_truth: list[str]) -> dict:
    pred = set(predicted)
    gt = set(ground_truth)
    if not pred and not gt:
        return {"precision": None, "recall": None, "tp": 0, "fp": 0, "fn": 0,
                "predicted": [], "ground_truth": []}
    tp = len(pred & gt)
    fp = len(pred - gt)
    fn = len(gt - pred)
    p = tp / (tp + fp) if (tp + fp) > 0 else 0.0
    r = tp / (tp + fn) if (tp + fn) > 0 else 0.0
    return {"precision": p, "recall": r, "tp": tp, "fp": fp, "fn": fn,
            "predicted": sorted(pred), "ground_truth": sorted(gt)}


def run_stage_hubrecall(manifest: dict, problems_subset: list[dict] | None = None,
                         active_models: list[str] | None = None,
                         max_workers: int = 4) -> dict:
    active_models = active_models or list(manifest["models"])
    problems = problems_subset or manifest["problems"]
    # Skip problems with no ground-truth hubs (can't score them)
    problems = [p for p in problems if p.get("ground_truth_hubs")]
    print(f"[hubrecall] {len(problems)} problems × {len(active_models)} models = {len(problems)*len(active_models)} calls")
    out_root = EVAL_DIR / "stage3_hubrecall"
    out_root.mkdir(parents=True, exist_ok=True)

    hubs, hub_catalog_str = _load_hub_catalog()

    def _one(p, m):
        pid = p["problem_id"]
        prompt = HUB_RECALL_PROMPT.format(
            n_hubs=len(hubs),
            statement_en=p["statement_en"][:1500],
            hub_catalog=hub_catalog_str,
        )
        t0 = time.time()
        result = run_attempt(m, prompt, timeout=DEFAULT_TIMEOUT)
        wall = round(time.time() - t0, 1)
        text = result.get("response_text") or ""
        parsed = _parse_hub_response(text)
        s = _score_hub(parsed["hubs"], p["ground_truth_hubs"])
        out = {"problem_id": pid, "model": m, "wall_seconds": wall,
               "predicted": s["predicted"], "ground_truth": s["ground_truth"],
               "precision": s["precision"], "recall": s["recall"],
               "tp": s["tp"], "fp": s["fp"], "fn": s["fn"],
               "rationale": parsed.get("rationale", ""), "raw_excerpt": text[:300]}
        (out_root / m.replace("/", "_")).mkdir(parents=True, exist_ok=True)
        (out_root / m.replace("/", "_") / f"{pid}.json").write_text(
            json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8"
        )
        return out

    results = []
    with ThreadPoolExecutor(max_workers=max_workers) as ex:
        futures = {ex.submit(_one, p, m): (p["problem_id"], m)
                   for p in problems for m in active_models}
        for fut in as_completed(futures):
            pid, m = futures[fut]
            try:
                r = fut.result()
                results.append(r)
                p, rc = r.get("precision"), r.get("recall")
                pstr = "n/a" if p is None else f"{p:.2f}"
                rstr = "n/a" if rc is None else f"{rc:.2f}"
                print(f"  [hubrecall] {m:<22} {pid:<40} P={pstr} R={rstr}")
            except Exception as e:
                print(f"  [hubrecall] [ERR] {m} {pid}: {e}")

    # Per-model averages
    per_model = {}
    for m in active_models:
        rs = [r for r in results if r["model"] == m and r.get("precision") is not None]
        if not rs:
            per_model[m] = {"avg_precision": None, "avg_recall": None, "avg_f1": None, "n": 0}
            continue
        ap = sum(r["precision"] for r in rs) / len(rs)
        ar = sum(r["recall"] for r in rs) / len(rs)
        af = (2 * ap * ar / (ap + ar)) if (ap + ar) > 0 else 0.0
        per_model[m] = {"avg_precision": ap, "avg_recall": ar, "avg_f1": af, "n": len(rs)}

    summary = {"timestamp": _now_iso(), "n_problems": len(problems),
               "models": active_models, "per_model": per_model, "results": results}
    (out_root / "hubrecall_summary.json").write_text(
        json.dumps(summary, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    print()
    print("=== HUB-RECALL ===")
    for m, v in per_model.items():
        if v["n"] == 0:
            print(f"  {m:<22} no scoreable results")
        else:
            print(f"  {m:<22} P={v['avg_precision']:.3f} R={v['avg_recall']:.3f} F1={v['avg_f1']:.3f}  (n={v['n']})")
    return summary


# ============================== Step 2.9: Aggregate + figures + summary ==============================


def aggregate(manifest: dict) -> dict:
    """Reduce all stage outputs to a single aggregate.json."""
    out: dict = {"timestamp": _now_iso(), "manifest_timestamp": manifest.get("timestamp")}

    # Stage 2 leaderboard
    main_dir = EVAL_DIR / "stage2_main"
    leaderboard: dict = {}
    sympy_ablation: dict = {}
    anomalies: list = []
    if main_dir.exists():
        for sp in main_dir.glob("*/*/*/summary.json"):
            try:
                s = json.loads(sp.read_text())
            except Exception as e:
                anomalies.append({"file": str(sp), "error": f"parse: {e}"})
                continue
            m = s["model"]; c = s["condition"]
            key = f"{m}|{c}"
            d = leaderboard.setdefault(key, {
                "model": m, "condition": c, "n": 0, "pass": 0,
                "lean_proof": 0, "sympy_rescue": 0, "instruction_violation": 0,
                "compile_fail": 0, "model_timeout": 0, "model_failed": 0,
                "wall_seconds_total": 0.0,
            })
            d["n"] += 1
            d["wall_seconds_total"] += s.get("wall_seconds", 0.0) or 0.0
            if s.get("overall_success"):
                d["pass"] += 1
            # Find a representative outcome — take last attempt's outcome, default model_timeout
            why = s.get("why_success")
            if why:
                d[why] = d.get(why, 0) + 1
            else:
                last = (s.get("attempts") or [{}])[-1] if s.get("attempts") else {}
                last_outcome = last.get("outcome", "compile_fail")
                if last_outcome not in d:
                    d[last_outcome] = 0
                d[last_outcome] += 1
            if s.get("codex_judge_action"):
                anomalies.append({
                    "type": "codex_judge", "problem_id": s["problem_id"],
                    "model": m, "condition": c,
                    "action": s["codex_judge_action"], "reason": s.get("codex_judge_reason"),
                })
        for d in leaderboard.values():
            d["pass_rate"] = d["pass"] / d["n"] if d["n"] else 0.0

    # Sympy ablation per model
    models = sorted({d["model"] for d in leaderboard.values()})
    for m in models:
        a = next((d for d in leaderboard.values() if d["model"] == m and d["condition"] == "lean_only"), None)
        b = next((d for d in leaderboard.values() if d["model"] == m and d["condition"] == "with_sympy"), None)
        if a and b:
            sympy_ablation[m] = {"lean_only": a["pass_rate"], "with_sympy": b["pass_rate"],
                                  "delta": b["pass_rate"] - a["pass_rate"]}

    # Stage 3 hub-recall
    hubsum_file = EVAL_DIR / "stage3_hubrecall" / "hubrecall_summary.json"
    hub_recall = json.loads(hubsum_file.read_text())["per_model"] if hubsum_file.exists() else {}

    # Stage 1 smoke
    smoke_file = EVAL_DIR / "stage1_smoke" / "smoke_summary.json"
    smoke = json.loads(smoke_file.read_text()) if smoke_file.exists() else {}

    out["smoke"] = smoke.get("per_model", {})
    out["leaderboard"] = leaderboard
    out["sympy_ablation"] = sympy_ablation
    out["hub_recall"] = hub_recall
    out["anomalies"] = anomalies
    out["preflight"] = json.loads(PREFLIGHT_FILE.read_text())["checks"] if PREFLIGHT_FILE.exists() else {}

    (EVAL_DIR / "aggregate.json").write_text(
        json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return out


def write_figures(agg: dict) -> None:
    """4 PNGs via matplotlib."""
    try:
        import matplotlib
        matplotlib.use("Agg")
        import matplotlib.pyplot as plt
    except Exception as e:
        print(f"[figures] matplotlib unavailable, skipping figures: {e}")
        return
    fig_dir = EVAL_DIR / "figures"
    fig_dir.mkdir(parents=True, exist_ok=True)

    # Leaderboard pass rate by model × condition
    if agg.get("leaderboard"):
        models = sorted({d["model"] for d in agg["leaderboard"].values()})
        conds = ["lean_only", "with_sympy"]
        x = list(range(len(models)))
        width = 0.4
        fig, ax = plt.subplots(figsize=(8, 4))
        for i, c in enumerate(conds):
            heights = []
            for m in models:
                d = next((d for d in agg["leaderboard"].values() if d["model"] == m and d["condition"] == c), None)
                heights.append(d["pass_rate"] if d else 0)
            ax.bar([xi + (i - 0.5) * width for xi in x], heights, width, label=c)
        ax.set_xticks(x); ax.set_xticklabels(models, rotation=20, ha="right")
        ax.set_ylabel("pass rate"); ax.set_ylim(0, 1)
        ax.set_title("Leaderboard pass rate (model × condition)")
        ax.legend()
        fig.tight_layout()
        fig.savefig(fig_dir / "leaderboard_pass_rate.png", dpi=120)
        plt.close(fig)

    # Sympy ablation
    if agg.get("sympy_ablation"):
        models = list(agg["sympy_ablation"].keys())
        deltas = [agg["sympy_ablation"][m]["delta"] for m in models]
        fig, ax = plt.subplots(figsize=(7, 3.5))
        ax.bar(models, deltas, color=["g" if d > 0 else "r" for d in deltas])
        ax.axhline(0, color="k", linewidth=0.5)
        ax.set_ylabel("Δ pass rate (with_sympy − lean_only)")
        ax.set_title("Sympy-skill ablation")
        plt.setp(ax.get_xticklabels(), rotation=20, ha="right")
        fig.tight_layout()
        fig.savefig(fig_dir / "sympy_ablation.png", dpi=120)
        plt.close(fig)

    # Outcome breakdown stacked
    if agg.get("leaderboard"):
        # Aggregate per-model totals across both conditions
        models = sorted({d["model"] for d in agg["leaderboard"].values()})
        outcome_keys = ["lean_proof", "sympy_rescue", "instruction_violation",
                         "compile_fail", "model_timeout", "model_failed"]
        totals = {m: {k: 0 for k in outcome_keys} for m in models}
        for d in agg["leaderboard"].values():
            for k in outcome_keys:
                totals[d["model"]][k] = totals[d["model"]].get(k, 0) + d.get(k, 0)
        fig, ax = plt.subplots(figsize=(8, 4))
        bottom = [0] * len(models)
        for k in outcome_keys:
            heights = [totals[m][k] for m in models]
            ax.bar(models, heights, bottom=bottom, label=k)
            bottom = [b + h for b, h in zip(bottom, heights)]
        ax.set_ylabel("attempts")
        ax.set_title("Outcome breakdown by model (both conditions combined)")
        ax.legend(loc="upper right", fontsize=8)
        plt.setp(ax.get_xticklabels(), rotation=20, ha="right")
        fig.tight_layout()
        fig.savefig(fig_dir / "outcome_breakdown.png", dpi=120)
        plt.close(fig)

    # Hub-recall P/R
    if agg.get("hub_recall"):
        models = list(agg["hub_recall"].keys())
        ps = [agg["hub_recall"][m].get("avg_precision") or 0 for m in models]
        rs = [agg["hub_recall"][m].get("avg_recall") or 0 for m in models]
        x = list(range(len(models)))
        width = 0.4
        fig, ax = plt.subplots(figsize=(7, 3.5))
        ax.bar([xi - width / 2 for xi in x], ps, width, label="precision")
        ax.bar([xi + width / 2 for xi in x], rs, width, label="recall")
        ax.set_xticks(x); ax.set_xticklabels(models, rotation=20, ha="right")
        ax.set_ylim(0, max(0.5, max(ps + rs + [0.1]) * 1.2))
        ax.set_title("Hub-recall (Mode A) — precision / recall by model")
        ax.legend()
        fig.tight_layout()
        fig.savefig(fig_dir / "hub_recall_pr.png", dpi=120)
        plt.close(fig)


def write_morning_summary(agg: dict, manifest: dict) -> None:
    out = EVAL_DIR / "morning_summary.md"
    lines = []
    lines.append("# Overnight Run — Morning Summary")
    lines.append(f"**Generated**: {agg.get('timestamp')}    **Manifest**: {agg.get('manifest_timestamp')}")
    lines.append("")
    lines.append("## Headline numbers")
    lines.append(f"- Models: {', '.join(manifest.get('models', []))}")
    lines.append(f"- Problems: {manifest.get('n_problems')} (sampled from FAITHFUL audit pool of 148)")
    lb = agg.get("leaderboard", {}) or {}
    n_cells = sum(d["n"] for d in lb.values())
    n_pass = sum(d["pass"] for d in lb.values())
    lines.append(f"- Total cells: {n_cells}  passes: {n_pass}")
    # Count all decision_log entries (cell-level + free-standing model-drop / throttle / etc.)
    n_consults = 0
    if DECISION_LOG.exists():
        n_consults = sum(1 for _ in DECISION_LOG.open())
    lines.append(f"- Codex-judge consultations: {n_consults}")
    lines.append("")

    lines.append("## Prover leaderboard (Pass@K)")
    lines.append("")
    lines.append("| model | condition | pass_rate | lean_proof | sympy_rescue | instruction_violation | compile_fail | model_timeout | n |")
    lines.append("|---|---|---:|---:|---:|---:|---:|---:|---:|")
    for k in sorted(lb.keys()):
        d = lb[k]
        lines.append(
            f"| {d['model']} | {d['condition']} | {d['pass_rate']:.2f} | "
            f"{d.get('lean_proof', 0)} | {d.get('sympy_rescue', 0)} | "
            f"{d.get('instruction_violation', 0)} | {d.get('compile_fail', 0)} | "
            f"{d.get('model_timeout', 0)} | {d['n']} |"
        )
    lines.append("")

    lines.append("## Sympy-skill ablation (Δ pass rate)")
    lines.append("")
    abl = agg.get("sympy_ablation", {}) or {}
    lines.append("| model | lean_only | with_sympy | Δ |")
    lines.append("|---|---:|---:|---:|")
    for m in sorted(abl.keys()):
        v = abl[m]
        lines.append(f"| {m} | {v['lean_only']:.2f} | {v['with_sympy']:.2f} | {v['delta']:+.2f} |")
    lines.append("")

    lines.append("## Hub-recall task")
    lines.append("")
    hr = agg.get("hub_recall", {}) or {}
    lines.append("| model | precision | recall | F1 | n |")
    lines.append("|---|---:|---:|---:|---:|")
    for m in sorted(hr.keys()):
        v = hr[m]
        if v.get("n", 0) == 0 or v.get("avg_precision") is None:
            lines.append(f"| {m} | n/a | n/a | n/a | 0 |")
        else:
            lines.append(f"| {m} | {v['avg_precision']:.3f} | {v['avg_recall']:.3f} | {v['avg_f1']:.3f} | {v['n']} |")
    lines.append("")

    lines.append("## Anomalies")
    for a in agg.get("anomalies", [])[:20]:
        lines.append(f"- {a}")
    if not agg.get("anomalies"):
        lines.append("- (none)")
    lines.append("")
    lines.append("## What to look at first")
    lines.append("1. `figures/leaderboard_pass_rate.png` — model × condition pass rates.")
    lines.append("2. `figures/sympy_ablation.png` — Δ from sympy-skill.")
    lines.append("3. `figures/hub_recall_pr.png` — categorical-gap quantification.")
    lines.append("4. `decision_log.jsonl` — every codex-judge consultation.")
    lines.append("5. `aggregate.json` — full numbers.")

    out.write_text("\n".join(lines) + "\n", encoding="utf-8")


# ============================== CLI ==============================


def cmd_sample_only(args: argparse.Namespace) -> int:
    m = write_manifest(n=args.n_problems, seed=args.seed)
    print(f"Wrote manifest: {MANIFEST_FILE}")
    print(f"  n={m['n_problems']}  pinned={sum(1 for p in m['problems'] if p['pinned'])}")
    print(f"  difficulty: {Counter(p['difficulty'] for p in m['problems'])}")
    print(f"  problem_type: {Counter(p['problem_type'] for p in m['problems'])}")
    print(f"  with hub edges: {sum(1 for p in m['problems'] if p['ground_truth_hubs'])}/{m['n_problems']}")
    return 0


def cmd_preflight_only(args: argparse.Namespace) -> int:
    pr = preflight()
    print(json.dumps(pr["checks"], indent=2, ensure_ascii=False))
    if not pr["ok"]:
        print("PRE-FLIGHT FAILED.", file=sys.stderr)
        return 1
    print("PRE-FLIGHT OK.")
    return 0


def cmd_aggregate_only(args: argparse.Namespace) -> int:
    if not MANIFEST_FILE.exists():
        print(f"manifest missing: {MANIFEST_FILE}", file=sys.stderr)
        return 1
    manifest = json.loads(MANIFEST_FILE.read_text())
    agg = aggregate(manifest)
    write_figures(agg)
    write_morning_summary(agg, manifest)
    print(f"aggregate.json + figures + morning_summary.md → {EVAL_DIR}")
    return 0


def cmd_dry_run_3(args: argparse.Namespace) -> int:
    """Run all stages on the first 3 problems of the manifest."""
    if not MANIFEST_FILE.exists():
        write_manifest(n=args.n_problems, seed=args.seed)
    manifest = json.loads(MANIFEST_FILE.read_text())
    subset = manifest["problems"][:3]

    pr = preflight()
    if not pr["ok"]:
        print("Pre-flight failed; aborting dry-run.", file=sys.stderr)
        return 1

    print("=== Stage 1: smoke (3 problems × 5 models × K=2) ===")
    smoke = run_stage_smoke(manifest, n_problems=3, K=2, max_workers=args.max_workers)
    if smoke["abort"]:
        print("ABORT: a model returned 0/N in smoke. Continuing dry-run for diagnostics.", file=sys.stderr)

    print("\n=== Stage 2: main matrix (3 problems × 5 models × 2 conditions × K=2) ===")
    run_stage_main(manifest, problems_subset=subset,
                    max_workers=args.max_workers,
                    checkpoint_every=args.checkpoint_every,
                    K=2, resume=args.resume_if_crashed)

    print("\n=== Stage 3: hub-recall (3 problems × 5 models) ===")
    run_stage_hubrecall(manifest, problems_subset=subset, max_workers=args.max_workers)

    print("\n=== Stage 4: aggregate ===")
    agg = aggregate(manifest)
    write_figures(agg)
    write_morning_summary(agg, manifest)
    print(f"\nDone. → {EVAL_DIR}/morning_summary.md")
    return 0


def cmd_full_run(args: argparse.Namespace) -> int:
    """Production: pre-flight → smoke → main → hub-recall → aggregate."""
    t_start = time.time()
    if not MANIFEST_FILE.exists():
        write_manifest(n=args.n_problems, seed=args.seed)
    manifest = json.loads(MANIFEST_FILE.read_text())

    print("=== Pre-flight ===")
    pr = preflight()
    if not pr["ok"]:
        print(json.dumps(pr["checks"], indent=2), file=sys.stderr)
        print("PRE-FLIGHT FAILED. Aborting.", file=sys.stderr)
        return 1

    print("\n=== Stage 1: smoke ===")
    smoke_summary_file = EVAL_DIR / "stage1_smoke" / "smoke_summary.json"
    if args.resume_if_crashed and smoke_summary_file.exists():
        print(f"[smoke] Resume mode: loading existing smoke summary from {smoke_summary_file}")
        smoke = json.loads(smoke_summary_file.read_text())
        for m, s in smoke.get("per_model", {}).items():
            print(f"  [smoke·resumed] {m:<22} {s['success']}/{s['total']}")
    else:
        smoke = run_stage_smoke(manifest, n_problems=5, K=2, max_workers=args.max_workers)
    # Smoke is DIAGNOSTIC only — never drop models from the leaderboard based on it.
    # Sampled "non-pinned" problems are still drawn from FAITHFUL pool which contains
    # genuinely hard problems; a 0/5 in smoke often means the model is slow on this
    # particular subset (legitimate leaderboard signal), not that infrastructure broke.
    # Truly broken models will be caught by the in-matrix persistent-failure detector
    # (threshold 15) which calls codex-judge for each persistent-failure candidate.
    active_models = list(manifest["models"])
    weak = [m for m in active_models if smoke["per_model"][m]["success"] == 0]
    if weak:
        print(f"NOTE: {weak} got 0/5 in smoke — keeping in matrix; persistent-failure logic will catch true breakdowns.")
    if all(smoke["per_model"][m]["success"] == 0 for m in active_models):
        # Every model 0/5 — could indicate a true infra issue (lake broken, key revoked).
        # Consult codex; if it says continue, continue; if it says abort, abort.
        ctx = {"smoke_per_model": smoke["per_model"]}
        decision = consult_codex_judge(situation="all_models_zero_in_smoke",
                                        context=ctx, history=[])
        append_decision({"situation": "all_models_zero_in_smoke",
                         "context": ctx, "decision": decision})
        if decision["action"] not in ("retry", "escalate_log", "throttle", "patch_param"):
            print(f"ABORT: codex-judge recommended {decision['action']}; halting.", file=sys.stderr)
            return 1

    print(f"\n=== Stage 2: main matrix ({len(active_models)} models × {manifest['n_problems']} × 2 conds × K={manifest['K']}) ===")
    run_stage_main(manifest, active_models=active_models,
                    resume=args.resume_if_crashed,
                    max_workers=args.max_workers,
                    checkpoint_every=args.checkpoint_every,
                    K=manifest["K"])

    print(f"\n=== Stage 3: hub-recall ===")
    run_stage_hubrecall(manifest, active_models=active_models,
                          max_workers=args.max_workers)

    print(f"\n=== Stage 4: aggregate ===")
    agg = aggregate(manifest)
    write_figures(agg)
    write_morning_summary(agg, manifest)
    wall = round((time.time() - t_start) / 60, 1)
    print(f"\nDONE in {wall} min. → {EVAL_DIR}/morning_summary.md")
    return 0


def main() -> int:
    p = argparse.ArgumentParser(description="Phase 2 overnight runner")
    p.add_argument("--sample-only", action="store_true")
    p.add_argument("--preflight-only", action="store_true")
    p.add_argument("--aggregate-only", action="store_true")
    p.add_argument("--dry-run-3", action="store_true")
    p.add_argument("--resume-if-crashed", action="store_true")
    p.add_argument("--max-workers", type=int, default=DEFAULT_MAX_WORKERS)
    p.add_argument("--checkpoint-every", type=int, default=DEFAULT_CHECKPOINT_EVERY)
    p.add_argument("--seed", type=int, default=DEFAULT_SEED)
    p.add_argument("--n-problems", type=int, default=DEFAULT_N_PROBLEMS)
    p.add_argument("--stages", default="all")
    args = p.parse_args()

    if args.sample_only:
        return cmd_sample_only(args)
    if args.preflight_only:
        return cmd_preflight_only(args)
    if args.aggregate_only:
        return cmd_aggregate_only(args)
    if args.dry_run_3:
        return cmd_dry_run_3(args)
    return cmd_full_run(args)


if __name__ == "__main__":
    sys.exit(main())
