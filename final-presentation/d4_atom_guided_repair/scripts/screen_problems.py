"""
Phase 3: Baseline screening.
Run Codex on each of the 8 pre-registered problems with NO context (C0).
Save ALL outcomes for transparency. Pick the 3 that baseline-fail as our test set.
"""
import json, sys, time, subprocess, tempfile, os
from pathlib import Path

ART = Path('/workspace/final-presentation/d4_atom_guided_repair/artifacts')
ART.mkdir(parents=True, exist_ok=True)

# We need a "known correct answer" per problem. Hand-curated based on the source notes.
KNOWN_ANSWERS = {
    'sum-int-13':  {
        'answer': 'H_n >= (n+1)/(2n) + log(n)',
        'check_keywords': ['convex', 'integral', 'log', '(n+1)/(2n)'],
    },
    'termwise-3':  {
        'answer': '1 + 1/2! + ... + 1/N! < 3 (in fact < e ≈ 2.718)',
        'check_keywords': ['<3', '< 3', 'e', 'telescop'],
    },
    'termwise-13': {
        'answer': 'lim_{p->infinity} M_p = max(x_1,...,x_n)',
        'check_keywords': ['max', 'squeeze', 'lim'],
    },
    'sum-int-9':   {
        'answer': 'T_N is bounded for p > 1; e.g., T_N <= 1 + 1/((p-1) a_1^{p-1})',
        'check_keywords': ['bounded', 'integral', 'partial sum', 'converg'],
    },
    'sum-int-7':   {
        'answer': 'sum (x_k - x_{k-1})(1 - x_k) < 1/2',
        'check_keywords': ['1/2', 'integral', '\\int', 'monoton'],
    },
    'termwise-18': {
        'answer': 'lim sum log(1 + k/n^2) = 1/2',
        'check_keywords': ['1/2', 'taylor', 'log(1+x)', 'riemann'],
    },
    'termwise-27': {
        'answer': 'lim n|n J_n - 1| = 1/2 (J_n ~ 1/n - 1/(2n^2) + ...)',
        'check_keywords': ['1/2', 'taylor', 'asymptotic'],
    },
    'sum-int-10':  {
        'answer': 'S_n = 1 - (2/3)/sqrt(n) + o(1/sqrt(n))',
        'check_keywords': ['2/3', 'sqrt', 'integral', 'taylor'],
    },
}


def call_codex(prompt: str, timeout: int = 300) -> str | None:
    with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
        out = f.name
    try:
        r = subprocess.run(
            ['codex', 'exec', '-o', out, prompt],
            capture_output=True, text=True, timeout=timeout,
        )
        if r.returncode == 0 and Path(out).exists():
            return Path(out).read_text()
        return None
    except subprocess.TimeoutExpired:
        return None
    finally:
        try: os.unlink(out)
        except Exception: pass


def baseline_prompt(problem: dict) -> str:
    return f"""Solve this mathematics problem. Provide a complete solution with reasoning.

Problem: {problem['statement_en']}

Be precise and rigorous. State the final answer clearly at the end."""


def naive_score(output: str, known: dict) -> dict:
    """Quick keyword-based scoring. Returns 'pass'/'fail'/'unclear'."""
    if not output:
        return {'verdict': 'unclear', 'reason': 'no output'}
    lower_out = output.lower()
    matched = [k for k in known['check_keywords'] if k.lower() in lower_out]
    score = len(matched) / max(1, len(known['check_keywords']))
    if score >= 0.5:
        return {'verdict': 'pass', 'matched_keywords': matched, 'score': score}
    elif score >= 0.25:
        return {'verdict': 'unclear', 'matched_keywords': matched, 'score': score}
    else:
        return {'verdict': 'fail', 'matched_keywords': matched, 'score': score}


def main():
    pool = json.load(open(ART / 'problem_pool.json'))
    print(f'Screening {len(pool)} problems...\n')

    screening = []
    out_dir = ART / 'screening_outputs'
    out_dir.mkdir(exist_ok=True)

    for i, p in enumerate(pool, 1):
        pid = p['id']
        label = p['label']
        print(f'[{i}/{len(pool)}] {label} ({pid})')
        print(f'  problem: {p["statement_en"][:100]}...')

        prompt = baseline_prompt(p)
        t0 = time.time()
        output = call_codex(prompt)
        elapsed = time.time() - t0

        if output is None:
            print(f'  CODEX FAILED')
            screening.append({
                'label': label, 'id': pid, 'output': None,
                'verdict': 'codex_error', 'elapsed_s': round(elapsed, 1),
            })
            continue

        # Save raw output
        (out_dir / f'{label}.txt').write_text(output)

        # Naive scoring
        known = KNOWN_ANSWERS.get(pid, {})
        score = naive_score(output, known) if known else {'verdict': 'no_known'}

        print(f'  elapsed: {elapsed:.1f}s, output: {len(output)} chars, verdict: {score["verdict"]}')
        if score.get('matched_keywords'):
            print(f'  matched: {score["matched_keywords"]}')

        screening.append({
            'label': label,
            'id': pid,
            'output_path': str(out_dir / f'{label}.txt'),
            'output_chars': len(output),
            'output_preview': output[:300],
            'verdict': score['verdict'],
            'matched_keywords': score.get('matched_keywords', []),
            'score': score.get('score', 0),
            'known_answer': known.get('answer', ''),
            'elapsed_s': round(elapsed, 1),
        })

    # Save full screening results
    out_path = ART / 'screening_results.json'
    with open(out_path, 'w') as f:
        json.dump(screening, f, indent=2, ensure_ascii=False)

    # Summary
    print('\n' + '='*60)
    print('=== SCREENING SUMMARY ===')
    print('='*60)
    verdict_counts = {}
    for s in screening:
        verdict_counts[s['verdict']] = verdict_counts.get(s['verdict'], 0) + 1
    print(f'Verdicts: {verdict_counts}')

    print(f'\nPer-problem:')
    for s in screening:
        print(f"  {s['label']:<14} {s['verdict']:<10} (matched {len(s.get('matched_keywords', []))} keywords, score={s.get('score', 0):.2f})")

    # The "fails" or "unclears" become candidate test problems
    candidates = [s for s in screening if s['verdict'] in ('fail', 'unclear')]
    print(f'\nBaseline-failure candidates: {len(candidates)}')
    for s in candidates:
        print(f"  {s['label']} ({s['verdict']}): {s.get('output_preview', '')[:120]}")

    print(f'\nFull screening results saved to {out_path}')


if __name__ == '__main__':
    main()
