"""
Run the MVT-form inequality experiment.
Parses Codex's 100 cases of (f, op, g, c, d) and verifies each via point-sampling.
"""
import sys
import json
import re
import argparse
from pathlib import Path
from dataclasses import asdict
from collections import Counter

sys.path.insert(0, '/workspace/final-artifacts/scripts')
from mvt_inequality_verifier import verify_mvt_inequality


def extract_json_array(text: str):
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    fenced = re.search(r'```(?:json)?\s*\n(.*?)\n```', text, re.DOTALL)
    if fenced:
        try:
            return json.loads(fenced.group(1))
        except json.JSONDecodeError:
            pass
    bracket = re.search(r'\[\s*\{.*\}\s*\]', text, re.DOTALL)
    if bracket:
        try:
            return json.loads(bracket.group(0))
        except json.JSONDecodeError:
            pass
    return None


def run(codex_response: str, output_dir: str):
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)

    raw = Path(codex_response).read_text(encoding='utf-8')
    print(f"Codex response: {len(raw)} chars")

    cases = extract_json_array(raw)
    if cases is None:
        print("ERROR: could not parse JSON")
        return
    print(f"Parsed {len(cases)} cases\n")

    (out / 'cases_mvt_parsed.json').write_text(
        json.dumps(cases, indent=2, ensure_ascii=False), encoding='utf-8'
    )

    op_counts = Counter()
    for c in cases:
        op_counts[c.get('op', '?')] += 1
    print(f"Operator distribution: {dict(op_counts)}\n")

    print(f"Verifying {len(cases)} MVT inequalities...")
    verifications = []
    for i, c in enumerate(cases):
        r = verify_mvt_inequality(
            f_str=c.get('f', ''),
            op=c.get('op', '>'),
            g_str=c.get('g', ''),
            c_str=c.get('c', '-oo'),
            d_str=c.get('d', 'oo'),
            n_samples=200,
        )
        verifications.append({'idx': i, 'case': c, 'result': asdict(r)})
        if (i + 1) % 25 == 0:
            print(f"  {i+1}/{len(cases)}")

    (out / 'verifications_mvt.json').write_text(
        json.dumps(verifications, indent=2, ensure_ascii=False), encoding='utf-8'
    )

    n = len(verifications)
    parse_fail = sum(1 for v in verifications if not v['result']['valid_input'])
    holds = sum(1 for v in verifications if v['result']['valid_input'] and v['result']['holds_everywhere'])
    fail = sum(1 for v in verifications if v['result']['valid_input'] and not v['result']['holds_everywhere'])

    summary = {
        'total': n,
        'parse_failed': parse_fail,
        'holds_everywhere': holds,
        'has_counterexample': fail,
        'failure_rate_pct': round(fail / n * 100, 1) if n else 0,
        'op_distribution': dict(op_counts),
    }
    (out / 'summary_mvt.json').write_text(json.dumps(summary, indent=2))

    print(f"\n{'='*60}")
    print(f"=== EXPERIMENT SUMMARY (MVT-form inequalities) ===")
    print(f"{'='*60}")
    print(f"Total cases:      {n}")
    print(f"Parse failures:   {parse_fail}")
    print(f"Verified holds:   {holds}")
    print(f"Counterexamples:  {fail}")
    print(f"Failure rate:     {summary['failure_rate_pct']}%")
    print(f"\nOperator distribution: {dict(op_counts)}")

    if fail > 0:
        print(f"\n=== FAILURES (with counterexamples) ===")
        for v in verifications:
            if v['result']['valid_input'] and not v['result']['holds_everywhere']:
                c = v['case']
                ces = v['result']['counterexamples']
                ce = ces[0] if ces else None
                print(f"\n[{v['idx']+1}] (f(b)-f(a))/(b-a) {c.get('op')} {c.get('g')}, on ({c.get('c')}, {c.get('d')})")
                print(f"     f = {c.get('f')}")
                if ce:
                    print(f"     counterexample: a={ce['a']}, b={ce['b']}")
                    print(f"     LHS = {ce['lhs']}, g(a,b) = {ce['rhs_g']}, gap = {ce['gap']}")

    if parse_fail > 0:
        print(f"\n=== PARSE FAILURES ===")
        for v in verifications:
            if not v['result']['valid_input']:
                c = v['case']
                print(f"  [{v['idx']+1}] f={c.get('f')}, g={c.get('g')}: {v['result']['parse_error']}")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--codex-response',
        default='/workspace/final-presentation/d1_arbitration_case/artifacts/mvt_experiment/codex_response.txt')
    parser.add_argument('--output-dir',
        default='/workspace/final-presentation/d1_arbitration_case/artifacts/mvt_experiment')
    args = parser.parse_args()
    run(args.codex_response, args.output_dir)
