"""
Stage 7: Formalize each problem's English statement into a Lean 4 theorem statement.

Per problem:
  1. Ask Codex (gpt-5.4) for a Lean 4 file: import Mathlib + theorem with `:= by sorry`
  2. Compile via `lake env lean Scratch/<unique>.lean` from /workspace/docker
  3. If failure: feed error diagnostics back to Codex, retry (up to max_attempts)
  4. Save attempts, codex responses, and lean diagnostics per problem

Success criterion: lake exits 0 with no error diagnostics.
We only formalize the STATEMENT — proof is `sorry`.

Parallelism: ThreadPoolExecutor over independent problems. Each problem owns
its own scratch file (named by hash of problem id) so workers never collide.
"""

import argparse
import hashlib
import json
import os
import re
import subprocess
import sys
import tempfile
from concurrent.futures import ThreadPoolExecutor, as_completed
from pathlib import Path

ROOT = Path("/workspace/final-presentation/d2_curation_v2")
NODES_DIR = ROOT / "data" / "dataset_v2" / "nodes"
OUT_DIR = ROOT / "data" / "formalizations"
DOCKER = Path("/workspace/docker")
SCRATCH = DOCKER / "Scratch"

OUT_DIR.mkdir(parents=True, exist_ok=True)
SCRATCH.mkdir(parents=True, exist_ok=True)


PROMPT_INITIAL = """You are formalizing a mathematical statement into Lean 4 code.

Your job: produce a complete Lean 4 source file that:
  1. Begins with `import Mathlib`
  2. States the theorem with a clear name (you choose, e.g., `mainTheorem` or a slug of the title)
  3. Uses `:= by sorry` as the proof — we are NOT proving it, only type-checking the statement

The file MUST type-check (compile cleanly with `lake env lean`):
  - All variables, types, and hypotheses must be declared correctly
  - Use Mathlib types/notation: `ℕ`, `ℤ`, `ℚ`, `ℝ`, `ℂ`, `Finset`, `Set`, `Real.pi`, `Real.exp`, `Real.log`, `Real.sin`, `Real.cos`, etc.
  - Translate LaTeX (`\\sum`, `\\int`, `\\lim`) to Mathlib (`Finset.sum`, `∫`, `Filter.Tendsto`, `iSup`/`iInf`, etc.)
  - Use `Filter.atTop`, `nhds`, `Filter.Tendsto` for limits at infinity
  - Use `IsConvergent`, `Summable`, `HasSum` where appropriate
  - DO NOT use external lemma names that may not exist; if you reference a lemma it must be in Mathlib

If the original statement references "Theorem 2.1.1" or similar internal numbering, use a fresh theorem name like `mainTheorem`.

If the original statement is a counterexample / negation / "show NOT", state that exactly: e.g., `theorem foo : ¬ ∀ ...`.

If the original statement is a definition rather than a provable theorem, define a function or predicate; you can wrap a trivial check with `by sorry`.

English statement to formalize:
{statement_en}

Output ONLY the Lean code. NO markdown fences, NO commentary, NO explanation. The first line MUST be `import Mathlib`.
"""

PROMPT_RETRY = """The Lean code below failed to type-check. Fix the statement so it compiles cleanly with `:= by sorry` as the proof. Output a complete corrected Lean file.

Failing code:
{prev_code}

Compiler diagnostics (errors):
{diagnostics}

Common fixes:
  - Wrong type: use `ℕ`/`ℝ`/etc., or `Finset` vs `Set`
  - Missing notation: use `Finset.sum`, `Filter.Tendsto`, `Real.pi`, etc.
  - Unknown identifier: replace with the correct Mathlib name
  - Universe/coercion issues: add `(↑n : ℝ)` or similar coercions
  - Implicit arg inference failed: add explicit type annotations

Output ONLY the corrected Lean code. NO markdown fences, NO commentary. First line: `import Mathlib`.
"""


def safe_slot(pid: str) -> str:
    """Unique scratch filename per problem (collision-free)."""
    h = hashlib.md5(pid.encode('utf-8')).hexdigest()[:12]
    return f"Fmlz_{h}"


def safe_dirname(pid: str) -> str:
    """Filesystem-safe per-problem output directory name."""
    s = re.sub(r'[^A-Za-z0-9_\-]', '_', pid)
    return s[:80] or 'problem_' + hashlib.md5(pid.encode('utf-8')).hexdigest()[:8]


def codex_exec(prompt: str, model: str = "gpt-5.4", timeout: int = 240) -> str | None:
    """Single Codex call. Returns the agent's last message text, or None on failure."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
        out_file = f.name
    try:
        r = subprocess.run(
            ["codex", "exec", "-c", f'model="{model}"', "-o", out_file, prompt],
            capture_output=True, text=True, timeout=timeout,
        )
        if r.returncode == 0 and Path(out_file).exists():
            return Path(out_file).read_text(encoding='utf-8').strip()
        return None
    except subprocess.TimeoutExpired:
        return None
    finally:
        try: os.unlink(out_file)
        except Exception: pass


def strip_codeblock(text: str) -> str:
    """Remove markdown code fences if Codex wrapped output."""
    text = (text or '').strip()
    m = re.search(r'```(?:lean(?:4)?)?\s*\n(.*?)\n```', text, re.DOTALL)
    if m:
        return m.group(1).strip()
    return text


def parse_diagnostics(combined: str) -> list[dict]:
    """Parse Lean diagnostics. Handles both old `error:` and new `error(id):` formats."""
    diags = []
    cur = None
    # severity may be `error`, `warning`, `info`, optionally followed by (subkind)
    diag_re = re.compile(r'(.+?):(\d+):(\d+):\s+(error|warning|info)(?:\([^)]+\))?:\s*(.*)')
    for line in combined.splitlines():
        m = diag_re.match(line)
        if m:
            if cur: diags.append(cur)
            cur = {
                'file': m.group(1),
                'line': int(m.group(2)),
                'column': int(m.group(3)),
                'severity': m.group(4),
                'message': m.group(5),
            }
        elif cur:
            cur['message'] += '\n' + line
    if cur: diags.append(cur)
    return diags


def lean_compile(code: str, slot: str) -> dict:
    """Write code to Scratch/<slot>.lean and run `lake env lean`."""
    lean_file = SCRATCH / f"{slot}.lean"
    lean_file.write_text(code, encoding='utf-8')

    env = os.environ.copy()
    env['PATH'] = f"{os.path.expanduser('~')}/.elan/bin:" + env.get('PATH', '')

    try:
        r = subprocess.run(
            ["lake", "env", "lean", str(lean_file)],
            cwd=str(DOCKER),
            capture_output=True, text=True, timeout=180, env=env,
        )
        combined = (r.stdout or '') + '\n' + (r.stderr or '')
        diags = parse_diagnostics(combined)
        errors = [d for d in diags if d['severity'] == 'error']
        # Trust the parsed diagnostics over exit code: lake sometimes returns 0
        # even when there are real errors in the output.
        return {
            'success': len(errors) == 0,
            'exit_code': r.returncode,
            'diagnostics': diags,
            'errors_only': errors,
            'stderr_tail': (r.stderr or '')[-1500:],
        }
    except subprocess.TimeoutExpired:
        return {
            'success': False,
            'exit_code': -1,
            'diagnostics': [{'severity': 'error', 'message': 'lake env lean timed out'}],
            'errors_only': [{'severity': 'error', 'message': 'timeout'}],
        }


def format_diagnostics_for_prompt(diags: list[dict]) -> str:
    if not diags: return '(no diagnostics returned)'
    parts = []
    for d in diags[:8]:  # cap to 8 messages
        parts.append(f"line {d.get('line')}:{d.get('column')}: {d.get('severity')}: {d.get('message')}")
    return '\n'.join(parts)


def formalize_problem(problem: dict, max_attempts: int = 3) -> dict:
    pid = problem['id']
    statement = problem.get('statement_en', '')
    if not statement:
        return {'problem_id': pid, 'success': False, 'error': 'no statement_en'}

    out_dir = OUT_DIR / safe_dirname(pid)
    out_dir.mkdir(parents=True, exist_ok=True)
    slot = safe_slot(pid)

    attempts = []
    last_code = None
    last_errors = None
    success = False

    for attempt_idx in range(1, max_attempts + 1):
        if attempt_idx == 1:
            prompt = PROMPT_INITIAL.format(statement_en=statement)
        else:
            prompt = PROMPT_RETRY.format(
                prev_code=last_code,
                diagnostics=format_diagnostics_for_prompt(last_errors or []),
            )

        codex_response = codex_exec(prompt)
        if not codex_response:
            attempts.append({'attempt': attempt_idx, 'codex_failed': True})
            break

        code = strip_codeblock(codex_response)
        # Ensure import Mathlib is present (insurance)
        if 'import Mathlib' not in code.split('\n')[0:3] and not code.strip().startswith('import'):
            code = 'import Mathlib\n\n' + code

        (out_dir / f"attempt_{attempt_idx}.lean").write_text(code, encoding='utf-8')
        (out_dir / f"attempt_{attempt_idx}_codex_raw.txt").write_text(codex_response, encoding='utf-8')

        result = lean_compile(code, slot)
        # Save diagnostics (without the giant stderr_tail)
        diag_record = {k: v for k, v in result.items() if k != 'stderr_tail'}
        (out_dir / f"attempt_{attempt_idx}_diagnostics.json").write_text(
            json.dumps(diag_record, indent=2, ensure_ascii=False), encoding='utf-8'
        )

        attempts.append({
            'attempt': attempt_idx,
            'success': result['success'],
            'n_errors': len(result.get('errors_only', [])),
            'first_error_msg': (result['errors_only'][0]['message'][:200]
                                if result.get('errors_only') else None),
        })

        last_code = code
        last_errors = result.get('errors_only')

        if result['success']:
            success = True
            break

    summary = {
        'problem_id': pid,
        'english_title': problem.get('english_title', ''),
        'statement_en': statement[:500],
        'difficulty': problem.get('difficulty', ''),
        'domain': problem.get('domain', ''),
        'success': success,
        'attempts_used': len(attempts),
        'attempts': attempts,
        'final_code': last_code,
    }
    (out_dir / 'summary.json').write_text(
        json.dumps(summary, indent=2, ensure_ascii=False), encoding='utf-8'
    )
    return summary


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--limit', type=int, default=0, help='process N problems (0 = all)')
    parser.add_argument('--workers', type=int, default=4)
    parser.add_argument('--max-attempts', type=int, default=3)
    parser.add_argument('--skip-existing', action='store_true', help='skip problems with summary.json')
    args = parser.parse_args()

    # Load problem nodes
    problems = []
    for f in sorted(NODES_DIR.glob('*.json')):
        node = json.loads(f.read_text(encoding='utf-8'))
        if node.get('type') == 'problem' and node.get('statement_en'):
            problems.append(node)

    print(f"Found {len(problems)} problem nodes total")

    if args.limit > 0:
        problems = problems[:args.limit]

    if args.skip_existing:
        before = len(problems)
        problems = [p for p in problems if not (OUT_DIR / safe_dirname(p['id']) / 'summary.json').exists()]
        print(f"  skipping {before - len(problems)} already-formalized")

    print(f"Processing {len(problems)} problems with {args.workers} workers, max {args.max_attempts} attempts each")
    print()

    results = []
    with ThreadPoolExecutor(max_workers=args.workers) as ex:
        futures = {ex.submit(formalize_problem, p, args.max_attempts): p for p in problems}
        for fut in as_completed(futures):
            p = futures[fut]
            try:
                summary = fut.result()
                results.append(summary)
                status = '✓' if summary['success'] else '✗'
                attempts = summary.get('attempts_used', 0)
                pid_short = summary['problem_id'][:50]
                print(f"  [{status}] [{len(results):>3}/{len(problems)}] {pid_short:<55} ({attempts} attempts)")
            except Exception as e:
                print(f"  [ERR] {p['id']}: {e}")
                results.append({'problem_id': p['id'], 'success': False, 'exception': str(e)})

    # Aggregate
    n_success = sum(1 for r in results if r.get('success'))
    n_fail = len(results) - n_success
    success_attempts = [r['attempts_used'] for r in results if r.get('success') and r.get('attempts_used')]
    avg_attempts_to_success = (sum(success_attempts) / len(success_attempts)) if success_attempts else 0

    overall = {
        'total': len(results),
        'success': n_success,
        'fail': n_fail,
        'success_rate_pct': round(n_success / max(1, len(results)) * 100, 1),
        'avg_attempts_to_success': round(avg_attempts_to_success, 2),
    }
    (OUT_DIR / '_summary.json').write_text(json.dumps(overall, indent=2), encoding='utf-8')

    print(f"\n=== FORMALIZATION SUMMARY ===")
    print(f"Total processed:       {overall['total']}")
    print(f"Success:               {n_success} ({overall['success_rate_pct']}%)")
    print(f"Fail:                  {n_fail}")
    print(f"Avg attempts (success): {overall['avg_attempts_to_success']}")
    print(f"\nPer-problem outputs in: {OUT_DIR}")


if __name__ == '__main__':
    main()
