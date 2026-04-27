"""
Reasoning Arbitrator
Post-hoc verification of mathematical claims in model CoT output.
Uses an LLM agent to extract clean computational claims, then verifies with sympy.
"""

import re
import json
import os
import argparse
from dataclasses import dataclass, asdict, field
from pathlib import Path
from typing import Optional
import sys

# Add parent dir so we can import sympy_verifier
sys.path.insert(0, str(Path(__file__).parent))
from sympy_verifier import verify_claim, VerificationResult


@dataclass
class MathClaim:
    raw_text: str
    claim_type: str  # integral, equality, inequality, series, limit
    parsed: dict     # kwargs for verify_claim
    start: int = 0   # position in original text
    end: int = 0


@dataclass
class ArbitrationReport:
    total_claims: int = 0
    verified_correct: int = 0
    verified_incorrect: int = 0
    could_not_verify: int = 0
    claims: list = field(default_factory=list)
    extraction_method: str = "regex"  # "regex" or "llm"


# --- LLM-based claim extraction ---

EXTRACTION_PROMPT = """You are a mathematical claim extraction agent. Given a text containing mathematical reasoning, extract ALL verifiable computational claims — statements that a computer algebra system (sympy) could check.

For each claim, output a JSON object with:
- "raw_text": the original text of the claim as it appears
- "claim_type": one of "integral", "equality", "inequality", "limit", "series"
- "sympy_kwargs": the arguments to pass to the appropriate sympy verifier

The sympy_kwargs format depends on claim_type:
- equality: {"lhs_str": "<expr>", "rhs_str": "<expr>"}
- inequality: {"lhs_str": "<expr>", "op": "<|>|<=|>=", "rhs_str": "<expr>"}
- integral: {"integrand_str": "<expr>", "var_str": "<var>", "lower_str": "<expr>", "upper_str": "<expr>", "expected_str": "<expr>"}
- series: {"expr_str": "<expr>", "var_str": "<var>", "lower_str": "<expr>", "upper_str": "<expr>", "expected_str": "<expr>"}
- limit: {"expr_str": "<expr>", "var_str": "<var>", "point_str": "<expr>", "expected_str": "<expr>"}

Use sympy-compatible syntax in all expressions: pi (not π), oo (for infinity), ** (not ^), Max/Min, sqrt, etc.

ONLY extract claims that sympy can verify — concrete computations, not logical/structural claims.
Output a JSON array. If no verifiable claims found, output [].

Text to analyze:
"""


def _call_llm(prompt: str) -> str:
    """Call LLM via shared utility (Codex CLI -> Anthropic -> OpenAI)."""
    try:
        from llm_call import call_llm as _shared_call
        return _shared_call(prompt)
    except SystemExit:
        return None
    except Exception as e:
        print(f"  [WARNING] LLM call failed: {e}", file=sys.stderr)
        return None


def extract_claims_llm(text: str) -> list[MathClaim]:
    """Use an LLM to extract verifiable mathematical claims from text."""
    prompt = EXTRACTION_PROMPT + text[:6000]  # truncate very long texts
    response = _call_llm(prompt)
    if response is None:
        print("  [WARNING] No API key available, falling back to regex extraction", file=sys.stderr)
        return extract_claims_regex(text)

    # Parse JSON from response
    try:
        # Try to find JSON array in response
        json_match = re.search(r'\[.*\]', response, re.DOTALL)
        if json_match:
            claims_data = json.loads(json_match.group(0))
        else:
            claims_data = json.loads(response)
    except json.JSONDecodeError:
        print(f"  [WARNING] Could not parse LLM response as JSON, falling back to regex", file=sys.stderr)
        return extract_claims_regex(text)

    claims = []
    for item in claims_data:
        if not isinstance(item, dict):
            continue
        claim_type = item.get("claim_type", "unknown")
        sympy_kwargs = item.get("sympy_kwargs", {})
        raw_text = item.get("raw_text", str(sympy_kwargs))
        claims.append(MathClaim(
            raw_text=raw_text,
            claim_type=claim_type,
            parsed=sympy_kwargs,
        ))
    return claims


# --- Objective-declaration detection (proactive arbitration) ---

OBJECTIVE_PATTERN = re.compile(
    r'(?:OBJECTIVE|COMPUTE|EVALUATE|CALCULATE|I need to (?:compute|evaluate|calculate|verify)):\s*(.+?)(?:\n|$)',
    re.IGNORECASE
)


def extract_objectives(text: str) -> list[str]:
    """Detect objective declarations in model output for proactive arbitration."""
    return [m.group(1).strip() for m in OBJECTIVE_PATTERN.finditer(text)]


# --- Regex-based claim extraction (fallback) ---

COMPARISON_PATTERN = re.compile(
    r'(\d+/\d+|\\frac\{[^}]+\}\{[^}]+\}|[0-9.]+)\s*(>=|<=|>|<|\\geq|\\leq|\\ge|\\le)\s*(\d+/\d+|\\frac\{[^}]+\}\{[^}]+\}|[0-9.]+|1/\\pi|1/pi)',
)
NUMERIC_EQUALITY_PATTERN = re.compile(
    r'([\d./\*\+\-\(\) ]+)\s*=\s*([\d./\*\+\-\(\) ]+)',
)


def clean_latex(s: str) -> str:
    """Strip $ signs and common LaTeX wrappers."""
    s = s.strip().strip('$')
    s = re.sub(r'\\frac\{([^}]+)\}\{([^}]+)\}', r'(\1)/(\2)', s)
    s = s.replace('\\pi', 'pi').replace('π', 'pi')
    s = s.replace('\\cdot', '*').replace('\\times', '*')
    s = s.replace('\\sqrt', 'sqrt')
    s = s.replace('\\left', '').replace('\\right', '')
    s = s.replace('\\', '')
    return s.strip()


def extract_claims_regex(text: str) -> list[MathClaim]:
    """Regex-based fallback for claim extraction (no API needed)."""
    claims = []
    for m in COMPARISON_PATTERN.finditer(text):
        lhs = clean_latex(m.group(1))
        op = m.group(2).replace('\\geq', '>=').replace('\\leq', '<=').replace('\\ge', '>=').replace('\\le', '<=')
        rhs = clean_latex(m.group(3))
        claims.append(MathClaim(raw_text=m.group(0), claim_type="inequality",
                                parsed={"lhs_str": lhs, "op": op, "rhs_str": rhs},
                                start=m.start(), end=m.end()))
    for m in NUMERIC_EQUALITY_PATTERN.finditer(text):
        lhs, rhs = m.group(1).strip(), m.group(2).strip()
        if re.search(r'\d', lhs) and re.search(r'\d', rhs) and not re.match(r'^[a-zA-Z_]+$', lhs.strip()):
            claims.append(MathClaim(raw_text=m.group(0), claim_type="equality",
                                    parsed={"lhs_str": lhs, "rhs_str": rhs},
                                    start=m.start(), end=m.end()))
    return claims


def arbitrate(text: str, use_llm: bool = True) -> ArbitrationReport:
    """Scan text for math claims, verify each, produce report."""
    if use_llm:
        claims = extract_claims_llm(text)
        method = "llm"
    else:
        claims = extract_claims_regex(text)
        method = "regex"
    report = ArbitrationReport(total_claims=len(claims), extraction_method=method)

    for claim in claims:
        result = verify_claim(claim.claim_type, **claim.parsed)
        entry = {
            "raw_text": claim.raw_text,
            "type": claim.claim_type,
            "verified": result.verified,
            "correct": result.correct,
            "computed": result.computed_result,
            "expected": result.expected_result,
            "error": result.error,
        }
        report.claims.append(entry)

        if not result.verified:
            report.could_not_verify += 1
        elif result.correct:
            report.verified_correct += 1
        else:
            report.verified_incorrect += 1

    return report


def substitute(text: str, report: ArbitrationReport) -> str:
    """Replace incorrect claims with verified results (simple version)."""
    corrected = text
    for claim in report.claims:
        if claim["verified"] and not claim["correct"] and claim["computed"]:
            # Simple replacement of the raw text with a corrected annotation
            correction = f'{claim["raw_text"]} [CORRECTED: {claim["computed"]}]'
            corrected = corrected.replace(claim["raw_text"], correction, 1)
    return corrected


def format_report(report: ArbitrationReport) -> str:
    """Format report as readable markdown."""
    lines = [
        "# Reasoning Arbitration Report\n",
        f"**Total claims found:** {report.total_claims}",
        f"**Verified correct:** {report.verified_correct}",
        f"**Verified incorrect:** {report.verified_incorrect}",
        f"**Could not verify:** {report.could_not_verify}",
        "",
        "## Claims Detail\n",
    ]
    for i, claim in enumerate(report.claims, 1):
        status = "CORRECT" if claim["correct"] else "INCORRECT" if claim["verified"] else "UNVERIFIABLE"
        lines.append(f"### Claim {i} [{status}]")
        lines.append(f"- **Raw text:** `{claim['raw_text']}`")
        lines.append(f"- **Type:** {claim['type']}")
        if claim["computed"]:
            lines.append(f"- **Computed:** {claim['computed']}")
        if claim["error"]:
            lines.append(f"- **Error:** {claim['error']}")
        lines.append("")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Reasoning Arbitration: verify math claims in text")
    parser.add_argument("input", help="Path to text file (model output or trace)")
    parser.add_argument("--output", help="Path to save report", default=None)
    parser.add_argument("--json", help="Path to save JSON report", default=None)
    parser.add_argument("--regex", action="store_true", help="Use regex extraction instead of LLM")
    args = parser.parse_args()

    text = Path(args.input).read_text(encoding='utf-8')
    use_llm = not args.regex
    mode = "LLM" if use_llm else "regex"
    print(f"Scanning {args.input} ({len(text)} chars, extraction={mode})...")

    report = arbitrate(text, use_llm=use_llm)
    formatted = format_report(report)
    print(formatted)

    if args.output:
        Path(args.output).write_text(formatted, encoding='utf-8')
        print(f"\nReport saved to {args.output}")

    if args.json:
        with open(args.json, 'w') as f:
            json.dump(asdict(report), f, indent=2)
        print(f"JSON report saved to {args.json}")


if __name__ == "__main__":
    main()
