"""
Run the full monotonicity experiment:
1. Parse Codex's 100-case output
2. Verify each case with the monotonicity verifier
3. Produce summary statistics + per-case results
4. Save all artifacts
"""
import sys
import json
import re
import argparse
from pathlib import Path
from dataclasses import asdict
from collections import Counter

sys.path.insert(0, '/workspace/final-artifacts/scripts')
from monotonicity_verifier import verify_monotonic_increasing


def extract_json_array(text: str):
    """Extract a JSON array from Codex output, robust to fences and extra text."""
    # Try direct parse
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass

    # Strip markdown code fences
    fenced = re.search(r'```(?:json)?\s*\n(.*?)\n```', text, re.DOTALL)
    if fenced:
        try:
            return json.loads(fenced.group(1))
        except json.JSONDecodeError:
            pass

    # Find the first [ ... ] block
    bracket_match = re.search(r'\[\s*\{.*\}\s*\]', text, re.DOTALL)
    if bracket_match:
        try:
            return json.loads(bracket_match.group(0))
        except json.JSONDecodeError:
            pass

    # Try to fix common issues: trailing commas, single quotes, etc.
    raw = text
    # Find array bounds
    start = raw.find('[')
    end = raw.rfind(']')
    if start >= 0 and end > start:
        candidate = raw[start:end+1]
        try:
            return json.loads(candidate)
        except json.JSONDecodeError:
            pass

    return None


def classify_function(f_str: str) -> str:
    """Heuristically classify a function by family."""
    s = f_str.lower()
    has_trig = any(t in s for t in ['sin', 'cos', 'tan'])
    has_exp = 'exp' in s
    has_log = 'log' in s or 'ln' in s
    has_sqrt = 'sqrt' in s
    has_inv_trig = any(t in s for t in ['asin', 'acos', 'atan', 'arcsin', 'arccos', 'arctan'])

    families = []
    if has_trig and not has_inv_trig: families.append('trig')
    if has_inv_trig: families.append('inv_trig')
    if has_exp: families.append('exp')
    if has_log: families.append('log')
    if has_sqrt: families.append('sqrt')
    if '/' in f_str and 'x' in f_str.split('/')[1] if '/' in f_str else False:
        families.append('rational')
    if not families:
        families.append('polynomial')

    return '+'.join(families) if families else 'other'


def run_experiment(codex_response_path: str, output_dir: str):
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    raw = Path(codex_response_path).read_text(encoding='utf-8')
    print(f"Codex response: {len(raw)} chars")

    # Extract JSON
    cases = extract_json_array(raw)
    if cases is None:
        print("ERROR: Could not parse JSON array from Codex response.")
        (out / 'parse_error.txt').write_text("Failed to parse JSON. Raw response saved to codex_response.txt.")
        return

    print(f"Parsed {len(cases)} cases")

    # Save normalized cases
    (out / 'cases_parsed.json').write_text(
        json.dumps(cases, indent=2, ensure_ascii=False), encoding='utf-8'
    )

    # Classify functions
    classifications = Counter()
    for c in cases:
        f = c.get('f', '')
        classifications[classify_function(f)] += 1
    print(f"\nFunction families: {dict(classifications)}")

    # Verify each case
    print(f"\nVerifying {len(cases)} cases...")
    verifications = []
    for i, c in enumerate(cases):
        r = verify_monotonic_increasing(
            f_str=c.get('f', ''),
            c_str=c.get('c', '-oo'),
            d_str=c.get('d', 'oo'),
            n_samples=200,
        )
        verifications.append({
            'idx': i,
            'case': c,
            'family': classify_function(c.get('f', '')),
            'result': asdict(r),
        })
        # Progress
        if (i + 1) % 25 == 0:
            print(f"  {i+1}/{len(cases)}")

    (out / 'verifications.json').write_text(
        json.dumps(verifications, indent=2, ensure_ascii=False), encoding='utf-8'
    )

    # Tally results
    n_total = len(verifications)
    n_parse_failed = sum(1 for v in verifications if not v['result']['valid_input'])
    n_holds = sum(1 for v in verifications if v['result']['valid_input'] and v['result']['holds_everywhere'])
    n_failed = sum(1 for v in verifications if v['result']['valid_input'] and not v['result']['holds_everywhere'])

    failure_by_family = Counter()
    total_by_family = Counter()
    for v in verifications:
        fam = v['family']
        total_by_family[fam] += 1
        if v['result']['valid_input'] and not v['result']['holds_everywhere']:
            failure_by_family[fam] += 1

    summary = {
        'total_cases': n_total,
        'parse_failed': n_parse_failed,
        'holds_everywhere': n_holds,
        'has_counterexample': n_failed,
        'failure_rate': round(n_failed / n_total * 100, 1) if n_total else 0,
        'total_by_family': dict(total_by_family),
        'failure_by_family': dict(failure_by_family),
    }
    (out / 'summary.json').write_text(json.dumps(summary, indent=2))

    print(f"\n{'='*60}")
    print(f"=== EXPERIMENT SUMMARY ===")
    print(f"{'='*60}")
    print(f"Total cases generated by Codex: {n_total}")
    print(f"Parse failures (invalid input): {n_parse_failed}")
    print(f"Verified monotonic (PASSED):    {n_holds}")
    print(f"Counterexamples found (FAILED): {n_failed}")
    print(f"Failure rate:                   {summary['failure_rate']}%")
    print(f"\nBy function family:")
    for fam, total in sorted(total_by_family.items(), key=lambda x: -x[1]):
        fails = failure_by_family.get(fam, 0)
        rate = round(fails / total * 100, 1) if total else 0
        print(f"  {fam:<25} {fails}/{total}  ({rate}%)")

    # Show failures
    if n_failed > 0:
        print(f"\n=== ALL FAILURES ===")
        for v in verifications:
            if v['result']['valid_input'] and not v['result']['holds_everywhere']:
                c = v['case']
                ces = v['result']['counterexamples']
                ce = ces[0] if ces else None
                print(f"\n[{v['idx']+1}] f={c.get('f')}, c={c.get('c')}, d={c.get('d')}  [{v['family']}]")
                if ce:
                    print(f"    counterexample: a={ce['a']}, b={ce['b']}, "
                          f"f(a)={ce['f_a']}, f(b)={ce['f_b']}, "
                          f"diff_quotient={ce['difference_quotient']}")

    if n_parse_failed > 0:
        print(f"\n=== PARSE FAILURES ===")
        for v in verifications:
            if not v['result']['valid_input']:
                c = v['case']
                print(f"  [{v['idx']+1}] f={c.get('f')}, c={c.get('c')}, d={c.get('d')}: "
                      f"{v['result']['parse_error']}")

    print(f"\nFull results saved to {out}")
    return summary, verifications


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--codex-response',
        default='/workspace/final-presentation/d1_arbitration_case/artifacts/monotonicity_baseline/safe/codex_response.txt')
    parser.add_argument('--output-dir',
        default='/workspace/final-presentation/d1_arbitration_case/artifacts/monotonicity_baseline/safe')
    args = parser.parse_args()
    run_experiment(args.codex_response, args.output_dir)
