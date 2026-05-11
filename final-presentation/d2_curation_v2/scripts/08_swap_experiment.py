"""
Stage 8: Plan / Downstream Swap (Qualitative Case Study).

Tests the proposed PLAN -> REASON -> FORMALIZE prover architecture by swapping
strong (S = gpt-5.4) and weak (W) models per stage. For each (weak_model, problem)
we run a 4-cell matrix:

    Cell    Plan  Reason  Formalize
    W-W-W   W     W       W           weak baseline
    S-W-W   S     W       W           rescue via plan-injection
    W-S-S   W     S       S           rescue via downstream-injection
    S-S-S   S     S       S           strong reference + inclusion criterion

Inclusion: a problem is analyzable for (weak, problem) iff W-W-W=fail AND
S-S-S=success in the matrix run itself.

Single-shot per stage (no retries). Success = lake env lean produces 0 errors.

See /home/node/.claude/plans/dynamic-watching-wall.md for the full plan.
"""

import argparse
import hashlib
import json
import os
import re
import shutil
import subprocess
import sys
import tempfile
import time
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path("/workspace/final-presentation/d2_curation_v2")
NODES_DIR = ROOT / "data" / "dataset_v2" / "nodes"
FORMALIZATIONS_DIR = ROOT / "data" / "formalizations"
OUT_DIR = ROOT / "data" / "swap_experiment"
DOCKER = Path("/workspace/docker")
SCRATCH = DOCKER / "Scratch"

OUT_DIR.mkdir(parents=True, exist_ok=True)
SCRATCH.mkdir(parents=True, exist_ok=True)

STRONG_MODEL = "gpt-5.4"
CELL_LABELS = ("W-W-W", "S-W-W", "W-S-S", "S-S-S")

# ------------------------------ Prompts ------------------------------

PLAN_PROMPT = """You are decomposing a mathematical theorem into a list of subgoals — the first
step of a three-stage proof pipeline.

THEOREM (English):
{statement_en}

LEAN 4 SIGNATURE (verified):
{signature_block}

Output a markdown bullet list of the intermediate subgoals/lemmas needed to
prove this theorem, in the order you would attack them.

Rules:
  - Each bullet is one subgoal, in plain English (light LaTeX OK; NO Lean).
  - Number bullets `1.`, `2.`, ... so later stages can reference them.
  - Use as many bullets as the proof structure requires; typically 2–6.
  - Each bullet must introduce a genuine intermediate claim or reduction.
    Do NOT restate the theorem or just say "show the result holds."
  - Do NOT prove the subgoals. Do NOT write Lean. Just list them.
  - Output ONLY the bullet list. No preamble, no commentary.
"""

REASON_PROMPT = """You are writing the reasoning step of a three-stage proof pipeline.

THEOREM (English):
{statement_en}

PLAN:
{plan_text}

Write a complete English proof sketch that addresses each numbered plan step
explicitly in order.

Rules:
  - Continuous English prose. Reference plan bullets as "by plan step 1, ...".
  - Address every numbered plan step in order. Do not skip any.
  - Justify nontrivial inequalities, limits, or estimates explicitly. State
    which Mathlib-style lemma you would invoke (e.g., "by Cauchy–Schwarz",
    "by `Real.exp_pos`").
  - LaTeX OK; NO Lean code.
  - Concise but complete (no padding; no length minimum). Upper bound ~600 words.
  - Output ONLY the proof sketch. No preamble, no headings.
"""

FORMALIZE_PROMPT = """You are the formalization stage of a three-stage proof pipeline. You translate
an English proof sketch into Lean 4 that compiles against Mathlib.

THEOREM (English):
{statement_en}

PLAN:
{plan_text}

REASONING (English proof sketch):
{reason_text}

LEAN 4 THEOREM SIGNATURE (use VERBATIM — do NOT change name, hypotheses, or
conclusion):
{signature_block}

Output a complete Lean 4 source file that:
  1. Begins with `import Mathlib`.
  2. Contains the theorem with the EXACT signature above.
  3. Replaces `sorry` with a complete proof. Must compile cleanly.

Notation: `ℕ`/`ℤ`/`ℚ`/`ℝ`/`ℂ`, `Finset.sum`, `Filter.Tendsto`, `Filter.atTop`,
`nhds`, `Real.pi`, `Summable`, etc.

Tactics: `intro`, `rcases`, `obtain`, `have`, `calc`, `simp`, `ring`,
`linarith`, `nlinarith`, `gcongr`, `positivity`, `field_simp`, `omega`,
`norm_num`, etc.

Rules:
  - Do NOT use `sorry`, `admit`, or `axiom`.
  - Do NOT invent Mathlib lemma names. Prefer tactics over guessed names.
  - When helpful, reflect major plan steps as separate `have` blocks (not required).
  - Output ONLY Lean code. NO markdown fences. NO commentary.
  - First line must be `import Mathlib`. Signature must match byte-for-byte.
"""

# ------------------------------ Helpers (mirrored from Stage 7) ------------------------------


def safe_slot(pid: str, weak_model: str, cell_label: str) -> str:
    """Per-cell unique scratch slot. Includes weak_model so primary and ablation runs don't collide."""
    key = f"{pid}|{weak_model}|{cell_label}"
    h = hashlib.md5(key.encode("utf-8")).hexdigest()[:12]
    return f"Stage8_{h}"


def safe_dirname(pid: str) -> str:
    s = re.sub(r"[^A-Za-z0-9_\-]", "_", pid)
    return s[:80] or "p_" + hashlib.md5(pid.encode("utf-8")).hexdigest()[:8]


def codex_exec(prompt: str, model: str, timeout: int = 240) -> str | None:
    with tempfile.NamedTemporaryFile(mode="w", suffix=".txt", delete=False) as f:
        out_file = f.name
    try:
        r = subprocess.run(
            ["codex", "exec", "-c", f'model="{model}"', "-o", out_file, prompt],
            capture_output=True, text=True, timeout=timeout,
        )
        if r.returncode == 0 and Path(out_file).exists():
            return Path(out_file).read_text(encoding="utf-8").strip()
        return None
    except subprocess.TimeoutExpired:
        return None
    finally:
        try: os.unlink(out_file)
        except Exception: pass


def strip_codeblock(text: str) -> str:
    text = (text or "").strip()
    m = re.search(r"```(?:lean(?:4)?)?\s*\n(.*?)\n```", text, re.DOTALL)
    if m:
        return m.group(1).strip()
    return text


def parse_diagnostics(combined: str) -> list[dict]:
    diags = []
    cur = None
    diag_re = re.compile(r"(.+?):(\d+):(\d+):\s+(error|warning|info)(?:\([^)]+\))?:\s*(.*)")
    for line in combined.splitlines():
        m = diag_re.match(line)
        if m:
            if cur: diags.append(cur)
            cur = {
                "file": m.group(1),
                "line": int(m.group(2)),
                "column": int(m.group(3)),
                "severity": m.group(4),
                "message": m.group(5),
            }
        elif cur:
            cur["message"] += "\n" + line
    if cur: diags.append(cur)
    return diags


def lean_compile(code: str, slot: str) -> dict:
    lean_file = SCRATCH / f"{slot}.lean"
    lean_file.write_text(code, encoding="utf-8")

    env = os.environ.copy()
    env["PATH"] = f"{os.path.expanduser('~')}/.elan/bin:" + env.get("PATH", "")

    try:
        r = subprocess.run(
            ["lake", "env", "lean", str(lean_file)],
            cwd=str(DOCKER),
            capture_output=True, text=True, timeout=180, env=env,
        )
        combined = (r.stdout or "") + "\n" + (r.stderr or "")
        diags = parse_diagnostics(combined)
        errors = [d for d in diags if d["severity"] == "error"]
        return {
            "success": len(errors) == 0,
            "exit_code": r.returncode,
            "diagnostics": diags,
            "errors_only": errors,
            "stderr_tail": (r.stderr or "")[-1500:],
        }
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "exit_code": -1,
            "diagnostics": [{"severity": "error", "message": "lake env lean timed out"}],
            "errors_only": [{"severity": "error", "message": "timeout"}],
            "stderr_tail": "timeout",
        }


# ------------------------------ Stage 8 specific helpers ------------------------------


def extract_signature(stage7_code: str) -> dict:
    """Slice Stage 7's verified `final_code` at `:= by`. Returns header + body marker."""
    if ":= by" not in stage7_code:
        return {"signature_block": stage7_code.strip(), "ok": False, "reason": "no := by"}
    head, _ = stage7_code.split(":= by", 1)
    signature_block = head.rstrip() + " := by"
    if not signature_block.startswith("import"):
        # Most Stage 7 outputs have `import Mathlib` as the first line.
        if "import Mathlib" not in signature_block.split("\n")[0]:
            signature_block = "import Mathlib\n\n" + signature_block.lstrip()
    return {"signature_block": signature_block, "ok": True}


_THEOREM_HEADER_RE = re.compile(
    r"(?:theorem|lemma|example|def)\s+([A-Za-z_][A-Za-z0-9_']*)?",
    re.MULTILINE,
)


def _extract_theorem_block(code: str) -> tuple[str, str] | None:
    """Return (header_up_to_:=by, rest_after) if a theorem/lemma block exists, else None."""
    if ":= by" not in code:
        return None
    m = re.search(r"(theorem|lemma|example)\s+", code)
    if not m:
        return None
    head = code[m.start():]
    if ":= by" not in head:
        return None
    head_part, rest = head.split(":= by", 1)
    return head_part.rstrip() + " := by", rest


def _normalize(s: str) -> str:
    """For comparing theorem signatures, ignore whitespace differences."""
    return re.sub(r"\s+", " ", s).strip()


def splice_proof(signature_block: str, raw_model_output: str) -> dict:
    """
    Conservative splicing:
      - If model output contains a theorem block whose header matches signature_block
        (modulo whitespace), pass through as-is.
      - If model output contains a theorem block with a DIFFERENT header, return
        a deviation flag — caller treats this as failure.
      - If model output is just a tactic body (no theorem/lemma keyword), splice
        under the canonical signature with 2-space indent.

    Returns {code, signature_deviation, splice_action, deviation_detail}
    """
    code = strip_codeblock(raw_model_output)

    canonical = _extract_theorem_block(signature_block)
    canonical_header = canonical[0] if canonical else signature_block

    model_block = _extract_theorem_block(code)

    if model_block is None:
        # No theorem keyword found — treat the whole text as a proof body.
        body = code.strip()
        if body.startswith("by "):
            body = body[3:]
        indented = "\n".join(("  " + ln) if ln.strip() else "" for ln in body.split("\n"))
        spliced = signature_block + "\n" + indented + "\n"
        return {
            "code": spliced,
            "signature_deviation": False,
            "splice_action": "wrap",
            "deviation_detail": "no theorem keyword in model output; wrapped body under canonical signature",
        }

    model_header, model_rest = model_block
    if _normalize(model_header) == _normalize(canonical_header):
        # Headers match; pass through. Make sure import Mathlib is at the top.
        if "import Mathlib" not in code.split("\n", 5)[0:5][0:5][0]:
            # Search broader in case top has comments
            if "import Mathlib" not in code:
                code = "import Mathlib\n\n" + code.lstrip()
        return {
            "code": code,
            "signature_deviation": False,
            "splice_action": "passthrough",
            "deviation_detail": "",
        }

    # Headers differ — record deviation; do NOT silently splice.
    return {
        "code": code,
        "signature_deviation": True,
        "splice_action": "deviation",
        "deviation_detail": f"model header differs from canonical (modulo whitespace).\nCanonical: {_normalize(canonical_header)[:300]}\nModel:    {_normalize(model_header)[:300]}",
    }


def assess_plan_quality(plan_text: str, statement_en: str) -> dict:
    """Lightweight structural check on the PLAN output."""
    text = (plan_text or "").strip()
    if not text or text.startswith("(plan stage failed)"):
        return {"n_bullets": 0, "is_numbered": False, "is_nonempty": False, "appears_to_restate_theorem": False}
    # Count numbered bullets like "1." or "1)" or "- " etc.
    numbered = len(re.findall(r"^\s*\d+[.)]\s+", text, re.MULTILINE))
    bullets = len(re.findall(r"^\s*(?:[-*]|\d+[.)])\s+", text, re.MULTILINE))
    is_numbered = numbered >= max(1, bullets - 1)
    appears_to_restate = (bullets <= 1) and (
        len(text) <= max(80, int(len(statement_en) * 1.2))
    )
    return {
        "n_bullets": bullets,
        "is_numbered": is_numbered,
        "is_nonempty": True,
        "appears_to_restate_theorem": appears_to_restate,
    }


def model_for_stage(cell_label: str, weak_model: str, stage_idx: int) -> str:
    """cell_label is 'W-W-W' / 'S-W-W' / 'W-S-S' / 'S-S-S'. stage_idx 0=plan,1=reason,2=formalize."""
    parts = cell_label.split("-")
    flag = parts[stage_idx]
    return STRONG_MODEL if flag == "S" else weak_model


# ------------------------------ Cell run ------------------------------


def run_cell(
    problem: dict,
    weak_model: str,
    cell_label: str,
    signature_block: str,
    out_root: Path,
) -> dict:
    """Run one cell-run end-to-end. Writes 6 files, returns a dict summary."""
    pid = problem["id"]
    statement = problem.get("statement_en", "")
    cell_dir = out_root / cell_label
    cell_dir.mkdir(parents=True, exist_ok=True)

    plan_model = model_for_stage(cell_label, weak_model, 0)
    reason_model = model_for_stage(cell_label, weak_model, 1)
    formalize_model = model_for_stage(cell_label, weak_model, 2)

    stage_seconds = {"plan": None, "reason": None, "formalize": None, "compile": None}
    stage_failures: list[str] = []

    # Stage A: PLAN
    t0 = time.time()
    plan_prompt = PLAN_PROMPT.format(statement_en=statement, signature_block=signature_block)
    plan_text = codex_exec(plan_prompt, plan_model)
    stage_seconds["plan"] = round(time.time() - t0, 1)
    if not plan_text:
        plan_text = "(plan stage failed)"
        stage_failures.append("plan")
    (cell_dir / "plan.md").write_text(plan_text, encoding="utf-8")

    # Stage B: REASON
    t0 = time.time()
    if "plan" in stage_failures:
        reason_text = "(reason stage skipped: plan failed)"
        stage_seconds["reason"] = 0.0
    else:
        reason_prompt = REASON_PROMPT.format(statement_en=statement, plan_text=plan_text)
        reason_text = codex_exec(reason_prompt, reason_model)
        stage_seconds["reason"] = round(time.time() - t0, 1)
        if not reason_text:
            reason_text = "(reason stage failed)"
            stage_failures.append("reason")
    (cell_dir / "reason.md").write_text(reason_text, encoding="utf-8")

    # Stage C: FORMALIZE
    t0 = time.time()
    if stage_failures:
        formalize_raw = "(formalize stage skipped: upstream failure)"
        spliced = {"code": "", "signature_deviation": False, "splice_action": "skipped", "deviation_detail": ""}
        stage_seconds["formalize"] = 0.0
        stage_failures.append("formalize")
    else:
        formalize_prompt = FORMALIZE_PROMPT.format(
            statement_en=statement,
            plan_text=plan_text,
            reason_text=reason_text,
            signature_block=signature_block,
        )
        formalize_raw = codex_exec(formalize_prompt, formalize_model)
        stage_seconds["formalize"] = round(time.time() - t0, 1)
        if not formalize_raw:
            formalize_raw = "(formalize stage failed)"
            spliced = {"code": "", "signature_deviation": False, "splice_action": "skipped", "deviation_detail": ""}
            stage_failures.append("formalize")
        else:
            spliced = splice_proof(signature_block, formalize_raw)

    (cell_dir / "codex_raw.txt").write_text(formalize_raw, encoding="utf-8")
    (cell_dir / "proof.lean").write_text(spliced["code"] or "-- (no code produced)\n", encoding="utf-8")

    # Compile
    if not spliced["code"] or spliced["splice_action"] == "deviation":
        # Skip compile on deviation; record as failure with reason.
        compile_log = {
            "success": False,
            "skipped": True,
            "reason": "signature_deviation" if spliced["splice_action"] == "deviation" else "no_code",
            "splice_action": spliced["splice_action"],
            "deviation_detail": spliced.get("deviation_detail", ""),
            "errors_only": [],
        }
        stage_seconds["compile"] = 0.0
        success = False
        n_errors = 0
        first_error = compile_log.get("deviation_detail") or "no code produced"
    else:
        t0 = time.time()
        slot = safe_slot(pid, weak_model, cell_label)
        compile_log = lean_compile(spliced["code"], slot)
        stage_seconds["compile"] = round(time.time() - t0, 1)
        compile_log["splice_action"] = spliced["splice_action"]
        compile_log["signature_deviation"] = spliced["signature_deviation"]
        success = bool(compile_log.get("success"))
        n_errors = len(compile_log.get("errors_only", []))
        first_error = (
            compile_log["errors_only"][0]["message"][:300]
            if compile_log.get("errors_only")
            else None
        )

    # Save compile_log without giant stderr
    log_to_save = {k: v for k, v in compile_log.items() if k != "stderr_tail"}
    (cell_dir / "compile_log.json").write_text(
        json.dumps(log_to_save, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    plan_quality = assess_plan_quality(plan_text, statement)

    cell_record = {
        "problem_id": pid,
        "weak_model": weak_model,
        "cell": cell_label,
        "models": {"plan": plan_model, "reason": reason_model, "formalize": formalize_model},
        "success": success,
        "n_errors": n_errors,
        "first_error": first_error,
        "stage_failures": stage_failures,
        "stage_seconds": stage_seconds,
        "plan_quality": plan_quality,
        "splice_action": spliced.get("splice_action"),
        "signature_deviation": spliced.get("signature_deviation", False),
    }
    (cell_dir / "cell.json").write_text(
        json.dumps(cell_record, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return cell_record


# ------------------------------ Problem pool ------------------------------


def load_pool() -> list[dict]:
    """Load Stage 7 successes that are problems (not counterexamples) with `:= by sorry`."""
    pool = []
    summary_path = FORMALIZATIONS_DIR / "_summary.json"
    if not summary_path.exists():
        print(f"ERROR: {summary_path} not found", file=sys.stderr)
        sys.exit(1)
    # We iterate per-problem summary.json since _summary.json is just totals.
    for problem_dir in sorted(FORMALIZATIONS_DIR.iterdir()):
        if not problem_dir.is_dir(): continue
        sp = problem_dir / "summary.json"
        if not sp.exists(): continue
        st7 = json.loads(sp.read_text(encoding="utf-8"))
        if not st7.get("success"): continue
        pid = st7["problem_id"]
        node_path = NODES_DIR / f"{pid}.json"
        if not node_path.exists(): continue
        node = json.loads(node_path.read_text(encoding="utf-8"))
        if node.get("type") != "problem": continue
        if node.get("problem_type") not in {"theorem", "lemma", "exercise", "example"}: continue
        final_code = st7.get("final_code") or ""
        if ":= by" not in final_code: continue
        if "sorry" not in final_code: continue
        node["_stage7_final_code"] = final_code
        pool.append(node)
    return pool


def stride_sample(pool: list[dict], n: int, offset: int = 0) -> list[dict]:
    """Deterministic stride sampling: sort by (domain, id), then take n at uniform stride."""
    sorted_pool = sorted(pool, key=lambda x: (x.get("domain", ""), x["id"]))
    if len(sorted_pool) <= n:
        return sorted_pool
    stride = len(sorted_pool) / n
    indices = [int((i + 0.5) * stride + offset) % len(sorted_pool) for i in range(n)]
    # dedupe preserving order
    seen = set()
    picked = []
    for i in indices:
        if i in seen: continue
        seen.add(i)
        picked.append(sorted_pool[i])
    # If dedupe shrank below n, pad with consecutive nexts
    j = 0
    while len(picked) < n and j < len(sorted_pool):
        if j not in seen:
            picked.append(sorted_pool[j]); seen.add(j)
        j += 1
    return picked


# ------------------------------ Calibration ------------------------------


def calibrate(weak_model: str, n_initial: int, n_pick: int, workers: int, skip_existing: bool) -> dict:
    """Probe candidates with W-W-W and S-S-S; pick n_pick separating problems."""
    pool = load_pool()
    print(f"[CALIBRATION] Pool size after filtering: {len(pool)}")

    cal_root = OUT_DIR / "_calibration"
    cal_root.mkdir(parents=True, exist_ok=True)

    candidates = stride_sample(pool, n_initial, offset=0)
    probed_results: dict[str, dict] = {}  # pid -> {W-W-W: cell_record, S-S-S: cell_record}

    def submit_probe(executor, candidates_to_run):
        futures = {}
        for cand in candidates_to_run:
            pid = cand["id"]
            sig = extract_signature(cand["_stage7_final_code"])
            if not sig.get("ok"):
                continue
            sig_block = sig["signature_block"]
            cand_root = cal_root / safe_dirname(pid)
            for cell in ("W-W-W", "S-S-S"):
                cell_dir = cand_root / cell
                if skip_existing and (cell_dir / "compile_log.json").exists():
                    # Reload existing
                    try:
                        existing = json.loads((cell_dir / "cell.json").read_text(encoding="utf-8"))
                        probed_results.setdefault(pid, {})[cell] = existing
                        continue
                    except Exception:
                        pass
                fut = executor.submit(run_cell, cand, weak_model, cell, sig_block, cand_root)
                futures[fut] = (pid, cell)
        return futures

    print(f"[CALIBRATION] Probing {len(candidates)} candidates x 2 cells = {len(candidates)*2} cell-runs")
    n_done = 0
    n_total_planned = len(candidates) * 2
    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = submit_probe(executor, candidates)
        for fut in as_completed(futures):
            pid, cell = futures[fut]
            try:
                rec = fut.result()
                probed_results.setdefault(pid, {})[cell] = rec
                n_done += 1
                stage_secs = rec.get("stage_seconds") or {}
                stage_str = "/".join(str(stage_secs.get(k, "?")) for k in ("plan","reason","formalize","compile"))
                print(f"  [{n_done:>2}/{n_total_planned}] {pid[:50]:<55} {cell} success={rec['success']} stage_secs={stage_str}")
            except Exception as e:
                print(f"  [ERR] {pid} {cell}: {e}")

    # Build separation grid
    def is_separating(rec_dict):
        ww = rec_dict.get("W-W-W", {})
        ss = rec_dict.get("S-S-S", {})
        return (ww.get("success") is False) and (ss.get("success") is True)

    separating = [pid for pid, rec_dict in probed_results.items() if is_separating(rec_dict)]
    print(f"[CALIBRATION] Initial separating: {len(separating)} of {len(probed_results)}")

    # Auto-widen if needed (probe 4 more from same pool, different stride)
    if len(separating) < n_pick:
        print(f"[CALIBRATION] Widening: probing 4 more from same pool")
        already_probed_ids = set(probed_results.keys())
        extra = [c for c in stride_sample(pool, n_initial + 4, offset=1) if c["id"] not in already_probed_ids][:4]
        with ThreadPoolExecutor(max_workers=workers) as executor:
            futures = submit_probe(executor, extra)
            for fut in as_completed(futures):
                pid, cell = futures[fut]
                try:
                    rec = fut.result()
                    probed_results.setdefault(pid, {})[cell] = rec
                    print(f"  [WIDEN] {pid[:50]:<55} {cell} success={rec['success']}")
                except Exception as e:
                    print(f"  [ERR] {pid} {cell}: {e}")
        separating = [pid for pid, rec_dict in probed_results.items() if is_separating(rec_dict)]
        print(f"[CALIBRATION] After widening: {len(separating)} separating")

    # Pick top-3 by clean separation strength then domain diversity then lex
    def score(pid):
        rec = probed_results[pid]
        ww = rec.get("W-W-W", {})
        ss = rec.get("S-S-S", {})
        n_w_errors = ww.get("n_errors", 0) or 0
        s_compile = (ss.get("stage_seconds", {}) or {}).get("compile", 0) or 0
        # Higher W errors = clearer fail; non-trivial S compile time hints at non-trivial proof.
        return (n_w_errors, s_compile)

    by_id_node = {n["id"]: n for n in pool}
    sep_sorted = sorted(separating, key=lambda pid: (-score(pid)[0], -score(pid)[1], pid))
    picked: list[str] = []
    used_domains: set[str] = set()
    # First pass: prioritize new domains
    for pid in sep_sorted:
        if len(picked) == n_pick: break
        domain = by_id_node[pid].get("domain", "")
        if domain not in used_domains:
            picked.append(pid); used_domains.add(domain)
    # Second pass: fill remaining slots even if same domain
    for pid in sep_sorted:
        if len(picked) == n_pick: break
        if pid not in picked:
            picked.append(pid)

    rationale_parts = [
        f"Probed {len(probed_results)} candidates; {len(separating)} separating.",
        f"Picked {len(picked)} by (W-error count, S-compile time, lex) with domain diversity primary.",
    ]
    rationale = " ".join(rationale_parts)

    picks_record = {
        "weak_model": weak_model,
        "candidates_probed": list(probed_results.keys()),
        "separating": separating,
        "picked": picked,
        "rationale": rationale,
        "results": probed_results,
        "domain_of_picked": {pid: by_id_node[pid].get("domain", "") for pid in picked},
    }
    (cal_root / "_picks.json").write_text(
        json.dumps(picks_record, indent=2, ensure_ascii=False), encoding="utf-8"
    )

    print(f"[CALIBRATION] picked: {', '.join(f'{pid} ({by_id_node[pid].get('domain','?')})' for pid in picked)}")
    return picks_record


# ------------------------------ Matrix ------------------------------


def copy_calibration_cell(pid: str, cell_label: str, weak_model: str) -> bool:
    """Copy calibration cell into the matrix tree. Returns True if copied successfully."""
    cal_dir = OUT_DIR / "_calibration" / safe_dirname(pid) / cell_label
    matrix_dir = OUT_DIR / weak_model / safe_dirname(pid) / cell_label
    if not (cal_dir / "compile_log.json").exists():
        return False
    matrix_dir.mkdir(parents=True, exist_ok=True)
    for fname in ("plan.md", "reason.md", "proof.lean", "codex_raw.txt", "compile_log.json", "cell.json"):
        src = cal_dir / fname
        if src.exists():
            shutil.copy2(src, matrix_dir / fname)
    return True


def run_matrix(
    weak_model: str,
    picked_pids: list[str],
    workers: int,
    skip_existing: bool,
    reuse_calibration: bool,
) -> dict:
    """Run the 4-cell matrix for picked problems with this weak_model."""
    by_id_node = {n["id"]: n for n in load_pool()}
    matrix_root = OUT_DIR / weak_model
    matrix_root.mkdir(parents=True, exist_ok=True)

    pid_to_cells: dict[str, dict[str, dict]] = {}
    fresh_tasks: list[tuple[dict, str, str, Path]] = []

    for pid in picked_pids:
        if pid not in by_id_node:
            print(f"  WARNING: {pid} not in pool; skipping")
            continue
        problem = by_id_node[pid]
        sig = extract_signature(problem["_stage7_final_code"])
        if not sig.get("ok"):
            print(f"  WARNING: cannot extract signature for {pid}; skipping")
            continue
        sig_block = sig["signature_block"]
        problem_root = matrix_root / safe_dirname(pid)
        problem_root.mkdir(parents=True, exist_ok=True)

        for cell_label in CELL_LABELS:
            cell_dir = problem_root / cell_label
            existing_log = cell_dir / "compile_log.json"
            if skip_existing and existing_log.exists():
                # Reload
                try:
                    existing_cell = json.loads((cell_dir / "cell.json").read_text(encoding="utf-8"))
                    pid_to_cells.setdefault(pid, {})[cell_label] = existing_cell
                    continue
                except Exception:
                    pass
            # Try calibration reuse for W-W-W and S-S-S of the primary weak model
            if reuse_calibration and cell_label in ("W-W-W", "S-S-S"):
                if copy_calibration_cell(pid, cell_label, weak_model):
                    try:
                        existing_cell = json.loads((cell_dir / "cell.json").read_text(encoding="utf-8"))
                        pid_to_cells.setdefault(pid, {})[cell_label] = existing_cell
                        continue
                    except Exception:
                        pass
            fresh_tasks.append((problem, weak_model, cell_label, problem_root))

    print(f"[MATRIX {weak_model}] Fresh cell-runs: {len(fresh_tasks)} (rest copied/reused)")

    n_done = 0
    n_total = len(fresh_tasks)
    with ThreadPoolExecutor(max_workers=workers) as executor:
        futures = {
            executor.submit(run_cell, problem, weak_model, cell_label,
                            extract_signature(problem["_stage7_final_code"])["signature_block"],
                            problem_root): (problem["id"], cell_label)
            for problem, weak_model, cell_label, problem_root in fresh_tasks
        }
        for fut in as_completed(futures):
            pid, cell_label = futures[fut]
            try:
                rec = fut.result()
                pid_to_cells.setdefault(pid, {})[cell_label] = rec
                n_done += 1
                stage_secs = rec.get("stage_seconds") or {}
                stage_str = "/".join(str(stage_secs.get(k, "?")) for k in ("plan","reason","formalize","compile"))
                print(f"  [{n_done:>2}/{n_total}] {pid[:50]:<55} {cell_label} {weak_model} success={rec['success']} stage_secs={stage_str}")
            except Exception as e:
                print(f"  [ERR] {pid} {cell_label}: {e}")

    # Build per-weak-model summary
    matrix_summary: dict[str, dict] = {}
    for pid, cells in pid_to_cells.items():
        node = by_id_node[pid]
        ww = cells.get("W-W-W", {})
        ss = cells.get("S-S-S", {})
        analyzable = (ww.get("success") is False) and (ss.get("success") is True)
        matrix_summary[pid] = {
            "english_title": node.get("english_title", ""),
            "domain": node.get("domain", ""),
            "difficulty": node.get("difficulty", ""),
            "analyzable": analyzable,
            "unstable": (not analyzable) and any(c in cells for c in ("W-W-W", "S-S-S")),
            "cells": {
                cl: {
                    "success": cells.get(cl, {}).get("success"),
                    "n_errors": cells.get(cl, {}).get("n_errors"),
                    "first_error": cells.get(cl, {}).get("first_error"),
                    "stage_seconds": cells.get(cl, {}).get("stage_seconds"),
                    "stage_failures": cells.get(cl, {}).get("stage_failures"),
                    "splice_action": cells.get(cl, {}).get("splice_action"),
                    "signature_deviation": cells.get(cl, {}).get("signature_deviation"),
                }
                for cl in CELL_LABELS
            },
            "plan_quality": {
                "W": cells.get("W-W-W", {}).get("plan_quality"),
                "S": cells.get("S-S-S", {}).get("plan_quality"),
            },
        }

    out = {
        "weak_model": weak_model,
        "picked": picked_pids,
        "matrix": matrix_summary,
        "fresh_cell_runs": len(fresh_tasks),
    }
    (matrix_root / "_summary.json").write_text(
        json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8"
    )
    return out


# ------------------------------ Compare report ------------------------------


def build_compare_md(weak_model: str, picked_pids: list[str]) -> None:
    matrix_root = OUT_DIR / weak_model
    sections = [f"# Stage 8 swap experiment — `{weak_model}`\n"]
    by_id_node = {n["id"]: n for n in load_pool()}
    for pid in picked_pids:
        node = by_id_node.get(pid, {})
        problem_root = matrix_root / safe_dirname(pid)
        sections.append(f"\n## {node.get('english_title', pid)}  \n")
        sections.append(f"- pid: `{pid}` — domain: {node.get('domain','?')} — difficulty: {node.get('difficulty','?')}\n")
        sections.append(f"- statement: {node.get('statement_en','')[:400]}\n")

        # Outcomes table
        sections.append("\n### Outcomes\n")
        sections.append("| Cell | Success | n_errors | First error | Stage secs (P/R/F/C) |\n")
        sections.append("|------|---------|----------|-------------|----------------------|\n")
        for cl in CELL_LABELS:
            cell_json = problem_root / cl / "cell.json"
            if not cell_json.exists():
                sections.append(f"| {cl} | - | - | - | - |\n")
                continue
            r = json.loads(cell_json.read_text(encoding="utf-8"))
            ss = r.get("stage_seconds") or {}
            stage_str = "/".join(str(ss.get(k, "?")) for k in ("plan","reason","formalize","compile"))
            err = (r.get("first_error") or "")[:80].replace("\n", " ").replace("|", "\\|")
            sections.append(f"| {cl} | {r.get('success')} | {r.get('n_errors')} | {err} | {stage_str} |\n")

        # Plans side-by-side: W (from W-W-W) vs S (from S-S-S)
        sections.append("\n### Plans\n")
        for cl in ("W-W-W", "S-S-S"):
            plan_md = problem_root / cl / "plan.md"
            if plan_md.exists():
                sections.append(f"\n**{cl} plan** (model = {('weak' if cl=='W-W-W' else 'strong')}):\n\n")
                sections.append("```\n" + plan_md.read_text(encoding="utf-8")[:1500] + "\n```\n")
    (matrix_root / "compare.md").write_text("".join(sections), encoding="utf-8")


# ------------------------------ Top-level summary ------------------------------


def write_top_level_summary(picks: dict | None, weak_models_run: list[str]) -> None:
    out = {"weak_models": {}}
    for wm in weak_models_run:
        wm_summary_path = OUT_DIR / wm / "_summary.json"
        if wm_summary_path.exists():
            wm_data = json.loads(wm_summary_path.read_text(encoding="utf-8"))
            entry = {"matrix": wm_data.get("matrix", {})}
            if wm == weak_models_run[0] and picks:
                entry["calibration"] = {
                    "candidates_probed": picks.get("candidates_probed", []),
                    "separating": picks.get("separating", []),
                    "picked": picks.get("picked", []),
                    "rationale": picks.get("rationale", ""),
                }
            out["weak_models"][wm] = entry
    # Global counts
    total_cells = 0
    success_cells = 0
    for wm_data in out["weak_models"].values():
        for pid_data in wm_data.get("matrix", {}).values():
            for cl, c in pid_data.get("cells", {}).items():
                total_cells += 1
                if c.get("success"):
                    success_cells += 1
    out["global"] = {
        "total_matrix_cells": total_cells,
        "successful_matrix_cells": success_cells,
    }
    (OUT_DIR / "_summary.json").write_text(
        json.dumps(out, indent=2, ensure_ascii=False), encoding="utf-8"
    )


# ------------------------------ Main ------------------------------


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--weak-model", choices=["gpt-5.4-mini", "gpt-5.2", "all"], default="gpt-5.4-mini")
    parser.add_argument("--calibration-n", type=int, default=8)
    parser.add_argument("--pick-n", type=int, default=3)
    parser.add_argument("--workers", type=int, default=4)
    parser.add_argument("--skip-existing", action="store_true")
    parser.add_argument("--no-calibration", action="store_true",
                        help="Skip calibration and use --problems instead")
    parser.add_argument("--problems", type=str, default="",
                        help="Comma-separated problem IDs (used with --no-calibration)")
    args = parser.parse_args()

    t_start = time.time()

    # Determine which weak models to run
    if args.weak_model == "all":
        weak_models_run = ["gpt-5.4-mini", "gpt-5.2"]
    else:
        weak_models_run = [args.weak_model]

    # Calibration (only for primary weak model gpt-5.4-mini, unless --no-calibration)
    picks = None
    primary_weak = weak_models_run[0]
    if args.no_calibration:
        if not args.problems:
            print("ERROR: --no-calibration requires --problems pid1,pid2,pid3", file=sys.stderr)
            sys.exit(1)
        picked_pids = [p.strip() for p in args.problems.split(",") if p.strip()]
    else:
        if primary_weak != "gpt-5.4-mini":
            print(f"NOTE: calibration only runs for gpt-5.4-mini; using picked problems for other weak models")
        picks = calibrate(
            weak_model="gpt-5.4-mini",
            n_initial=args.calibration_n,
            n_pick=args.pick_n,
            workers=args.workers,
            skip_existing=args.skip_existing,
        )
        picked_pids = picks["picked"]
        if len(picked_pids) < args.pick_n:
            print(f"WARNING: only {len(picked_pids)} separating problems found; proceeding anyway")

    if not picked_pids:
        print("ERROR: no problems picked; nothing to run", file=sys.stderr)
        sys.exit(1)

    # Run matrix per weak model
    for wm in weak_models_run:
        print(f"\n=== MATRIX RUN: weak_model={wm} ===")
        run_matrix(
            weak_model=wm,
            picked_pids=picked_pids,
            workers=args.workers,
            skip_existing=args.skip_existing,
            reuse_calibration=(wm == "gpt-5.4-mini"),
        )
        build_compare_md(wm, picked_pids)

    # Top-level summary
    write_top_level_summary(picks, weak_models_run)

    wall_seconds = round(time.time() - t_start, 1)
    print(f"\n=== STAGE 8 SUMMARY (wall={wall_seconds}s) ===")
    for wm in weak_models_run:
        summary_path = OUT_DIR / wm / "_summary.json"
        if not summary_path.exists():
            print(f"  {wm}: (no summary)")
            continue
        wm_data = json.loads(summary_path.read_text(encoding="utf-8"))
        for pid, pid_data in wm_data.get("matrix", {}).items():
            cells = pid_data.get("cells", {})
            grid = " ".join(
                f"{cl}={'+' if cells.get(cl,{}).get('success') else '-' if cells.get(cl,{}).get('success') is False else '?'}"
                for cl in CELL_LABELS
            )
            tag = " [unstable]" if pid_data.get("unstable") else ""
            print(f"  {wm}  {pid[:40]:<42} {grid}{tag}")
    print(f"\nArtifacts: {OUT_DIR}")


if __name__ == "__main__":
    main()
