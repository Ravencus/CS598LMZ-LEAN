"""
Audit script: rerun arbitration on a saved T1 output with FULL logging.
Saves: input text, raw LLM response, parsed claims, per-claim verifications.
Goal: distinguish real CoT errors from extraction/regex artifacts.
"""
import sys
import json
import time
import argparse
from pathlib import Path

sys.path.insert(0, '/workspace/final-artifacts/scripts')
from reasoning_arbitrator import EXTRACTION_PROMPT, _call_llm
from sympy_verifier import verify_claim


def audit(text_path: str, label: str, output_dir: str):
    out = Path(output_dir) / label
    out.mkdir(parents=True, exist_ok=True)

    text = Path(text_path).read_text(encoding='utf-8')
    print(f'Input: {text_path} ({len(text)} chars)')
    (out / 'input.txt').write_text(text, encoding='utf-8')

    # 1. Run the actual extraction prompt
    prompt = EXTRACTION_PROMPT + text[:6000]  # match arbitrator behavior (truncates)
    (out / 'extraction_prompt.txt').write_text(prompt, encoding='utf-8')
    print(f'Prompt: {len(prompt)} chars (truncated input to 6000)')

    print('Calling LLM for claim extraction...')
    t0 = time.time()
    response = _call_llm(prompt)
    elapsed = time.time() - t0
    print(f'LLM call returned in {elapsed:.1f}s')

    if response is None:
        print('LLM call FAILED (returned None)')
        (out / 'audit_summary.json').write_text(json.dumps({
            'status': 'llm_call_failed',
            'elapsed_s': elapsed,
        }, indent=2))
        return
    (out / 'llm_raw_response.txt').write_text(response, encoding='utf-8')
    print(f'Raw LLM response: {len(response)} chars')

    # 2. Parse JSON from response (mirroring extract_claims_llm)
    import re
    json_match = re.search(r'\[.*\]', response, re.DOTALL)
    if json_match:
        try:
            claims_data = json.loads(json_match.group(0))
        except json.JSONDecodeError as e:
            print(f'JSON parse failed: {e}')
            (out / 'parse_error.txt').write_text(str(e))
            claims_data = []
    else:
        try:
            claims_data = json.loads(response)
        except json.JSONDecodeError:
            claims_data = []

    print(f'Parsed {len(claims_data)} claims from LLM response')
    (out / 'parsed_claims.json').write_text(
        json.dumps(claims_data, indent=2, ensure_ascii=False),
        encoding='utf-8'
    )

    # 3. Verify each claim
    print('\nVerifying each claim with sympy...')
    verifications = []
    for i, item in enumerate(claims_data):
        if not isinstance(item, dict):
            continue
        claim_type = item.get('claim_type', 'unknown')
        sympy_kwargs = item.get('sympy_kwargs', {})
        raw_text = item.get('raw_text', str(sympy_kwargs))

        try:
            result = verify_claim(claim_type, **sympy_kwargs)
            verifications.append({
                'idx': i,
                'raw_text': raw_text,
                'claim_type': claim_type,
                'sympy_kwargs': sympy_kwargs,
                'verified': result.verified,
                'correct': result.correct,
                'computed_result': result.computed_result,
                'expected_result': result.expected_result,
                'error': result.error,
            })
        except TypeError as e:
            # Schema mismatch (wrong kwargs)
            verifications.append({
                'idx': i,
                'raw_text': raw_text,
                'claim_type': claim_type,
                'sympy_kwargs': sympy_kwargs,
                'verified': False,
                'correct': False,
                'error': f'Schema mismatch: {e}',
            })

    (out / 'verifications.json').write_text(
        json.dumps(verifications, indent=2, ensure_ascii=False),
        encoding='utf-8'
    )

    # 4. Summary
    ok = sum(1 for v in verifications if v.get('verified') and v.get('correct'))
    wrong = sum(1 for v in verifications if v.get('verified') and not v.get('correct'))
    unverifiable = sum(1 for v in verifications if not v.get('verified'))
    schema_err = sum(1 for v in verifications if 'Schema mismatch' in str(v.get('error', '')))

    summary = {
        'status': 'ok',
        'elapsed_s': round(elapsed, 1),
        'input_chars': len(text),
        'llm_response_chars': len(response),
        'total_claims_parsed': len(claims_data),
        'total_verified_correct': ok,
        'total_verified_incorrect': wrong,
        'total_unverifiable': unverifiable,
        'total_schema_errors': schema_err,
    }
    (out / 'audit_summary.json').write_text(json.dumps(summary, indent=2))

    print(f'\n=== AUDIT SUMMARY ===')
    print(json.dumps(summary, indent=2))

    print(f'\n=== INCORRECT CLAIMS (real CoT errors) ===')
    for v in verifications:
        if v.get('verified') and not v.get('correct'):
            print(f"\n[{v['idx']+1}] {v['raw_text'][:200]}")
            print(f"    TYPE: {v['claim_type']}")
            print(f"    KWARGS: {v['sympy_kwargs']}")
            print(f"    COMPUTED: {v.get('computed_result')}")
            print(f"    EXPECTED: {v.get('expected_result')}")

    print(f'\n=== UNVERIFIABLE CLAIMS (extraction or sympy issues) ===')
    for v in verifications:
        if not v.get('verified'):
            print(f"\n[{v['idx']+1}] {v['raw_text'][:200]}")
            print(f"    TYPE: {v['claim_type']}")
            print(f"    KWARGS: {v.get('sympy_kwargs')}")
            print(f"    ERROR: {v.get('error')}")

    print(f'\nAll output saved to: {out}')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--text', required=True, help='Path to input text (e.g. T1 output)')
    parser.add_argument('--label', required=True, help='Label for this audit run (becomes subdir name)')
    parser.add_argument('--output-dir', default='/workspace/final-artifacts/results/raw_runs')
    args = parser.parse_args()

    audit(args.text, args.label, args.output_dir)
