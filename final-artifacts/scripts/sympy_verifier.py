"""
Sympy Verification Tool
Verifies mathematical claims (integrals, equalities, inequalities, limits, series)
using sympy as a ground-truth computation engine.
"""

import re
import json
from dataclasses import dataclass, asdict
from typing import Optional
import sympy
from sympy import (
    symbols, oo, pi, E, I, sqrt, Rational, Max, Min,
    integrate, limit, summation, simplify, sympify,
    sin, cos, tan, exp, log, Abs,
    Symbol, Function, FiniteSet
)
from sympy.parsing.sympy_parser import (
    parse_expr, standard_transformations,
    implicit_multiplication_application,
    convert_xor, function_exponentiation
)

TRANSFORMS = standard_transformations + (
    implicit_multiplication_application,
    convert_xor,
)


@dataclass
class VerificationResult:
    claim: str
    claim_type: str  # integral, equality, inequality, limit, series, unknown
    verified: bool   # whether we could check it
    correct: bool    # whether the claim is mathematically correct
    computed_result: Optional[str] = None
    expected_result: Optional[str] = None
    error: Optional[str] = None


def safe_parse(expr_str: str):
    """Try to parse a math expression string into a sympy expression."""
    # Clean up common LaTeX artifacts
    s = expr_str.strip()
    s = s.replace('\\', '')
    s = s.replace('{', '(').replace('}', ')')
    s = s.replace('^', '**')
    s = s.replace('cdot', '*')
    try:
        return parse_expr(s, transformations=TRANSFORMS)
    except Exception:
        pass
    try:
        return sympify(s)
    except Exception as e:
        return None


def verify_integral(integrand_str: str, var_str: str, lower_str: str, upper_str: str, expected_str: str) -> VerificationResult:
    """Verify a definite integral claim."""
    claim = f"integral of {integrand_str} from {lower_str} to {upper_str} = {expected_str}"
    try:
        var = Symbol(var_str)
        integrand = safe_parse(integrand_str)
        lower = safe_parse(lower_str)
        upper = safe_parse(upper_str)
        expected = safe_parse(expected_str)

        if any(x is None for x in [integrand, lower, upper, expected]):
            return VerificationResult(claim, "integral", False, False, error="Could not parse expression")

        result = integrate(integrand, (var, lower, upper))
        result_simplified = simplify(result)
        diff = simplify(result_simplified - expected)

        return VerificationResult(
            claim=claim, claim_type="integral", verified=True,
            correct=(diff == 0),
            computed_result=str(result_simplified),
            expected_result=str(expected)
        )
    except Exception as e:
        return VerificationResult(claim, "integral", False, False, error=str(e))


def verify_equality(lhs_str: str, rhs_str: str) -> VerificationResult:
    """Verify that two expressions are equal."""
    claim = f"{lhs_str} = {rhs_str}"
    try:
        lhs = safe_parse(lhs_str)
        rhs = safe_parse(rhs_str)
        if lhs is None or rhs is None:
            return VerificationResult(claim, "equality", False, False, error="Could not parse expression")

        diff = simplify(lhs - rhs)
        return VerificationResult(
            claim=claim, claim_type="equality", verified=True,
            correct=(diff == 0),
            computed_result=str(simplify(lhs)),
            expected_result=str(simplify(rhs))
        )
    except Exception as e:
        return VerificationResult(claim, "equality", False, False, error=str(e))


def verify_inequality(lhs_str: str, op: str, rhs_str: str) -> VerificationResult:
    """Verify an inequality (>=, <=, >, <)."""
    claim = f"{lhs_str} {op} {rhs_str}"
    try:
        lhs = safe_parse(lhs_str)
        rhs = safe_parse(rhs_str)
        if lhs is None or rhs is None:
            return VerificationResult(claim, "inequality", False, False, error="Could not parse expression")

        diff = simplify(lhs - rhs)
        # Try numerical evaluation
        diff_val = float(diff.evalf())

        op_map = {">=": diff_val >= 0, "<=": diff_val <= 0, ">": diff_val > 0, "<": diff_val < 0}
        correct = op_map.get(op, False)

        return VerificationResult(
            claim=claim, claim_type="inequality", verified=True,
            correct=correct,
            computed_result=f"{lhs_str} - ({rhs_str}) = {diff_val:.6f}",
            expected_result=f"difference should be {op} 0"
        )
    except Exception as e:
        return VerificationResult(claim, "inequality", False, False, error=str(e))


def verify_limit(expr_str: str, var_str: str, point_str: str, expected_str: str) -> VerificationResult:
    """Verify a limit claim."""
    claim = f"lim({var_str}->{point_str}) {expr_str} = {expected_str}"
    try:
        var = Symbol(var_str)
        expr = safe_parse(expr_str)
        point = safe_parse(point_str)
        expected = safe_parse(expected_str)

        if any(x is None for x in [expr, point, expected]):
            return VerificationResult(claim, "limit", False, False, error="Could not parse expression")

        result = limit(expr, var, point)
        diff = simplify(result - expected)

        return VerificationResult(
            claim=claim, claim_type="limit", verified=True,
            correct=(diff == 0),
            computed_result=str(result),
            expected_result=str(expected)
        )
    except Exception as e:
        return VerificationResult(claim, "limit", False, False, error=str(e))


def verify_series(expr_str: str, var_str: str, lower_str: str, upper_str: str, expected_str: str) -> VerificationResult:
    """Verify a series/summation claim."""
    claim = f"sum({var_str}={lower_str}..{upper_str}) {expr_str} = {expected_str}"
    try:
        var = Symbol(var_str)
        expr = safe_parse(expr_str)
        lower = safe_parse(lower_str)
        upper = safe_parse(upper_str)
        expected = safe_parse(expected_str)

        if any(x is None for x in [expr, lower, upper, expected]):
            return VerificationResult(claim, "series", False, False, error="Could not parse expression")

        result = summation(expr, (var, lower, upper))
        diff = simplify(result - expected)

        return VerificationResult(
            claim=claim, claim_type="series", verified=True,
            correct=(diff == 0),
            computed_result=str(result),
            expected_result=str(expected)
        )
    except Exception as e:
        return VerificationResult(claim, "series", False, False, error=str(e))


def verify_claim(claim_type: str, **kwargs) -> VerificationResult:
    """Dispatch to the appropriate verifier based on claim type."""
    verifiers = {
        "integral": verify_integral,
        "equality": verify_equality,
        "inequality": verify_inequality,
        "limit": verify_limit,
        "series": verify_series,
    }
    verifier = verifiers.get(claim_type)
    if verifier is None:
        return VerificationResult(str(kwargs), "unknown", False, False, error=f"Unknown claim type: {claim_type}")
    return verifier(**kwargs)


def run_tests():
    """Run built-in test cases from the case study."""
    print("=== Sympy Verifier Test Suite ===\n")

    x, n, u = symbols('x n u')

    tests = [
        # Test 1: The sorry'd integral from the averaging proof
        ("integral", {
            "integrand_str": "Max(cos(u), 0)",
            "var_str": "u",
            "lower_str": "0",
            "upper_str": "2*pi",
            "expected_str": "2"
        }),
        # Test 2: Simple inequality from the case study
        ("inequality", {
            "lhs_str": "1/6",
            "op": "<",
            "rhs_str": "1/pi"
        }),
        # Test 3: Series - Basel problem
        ("series", {
            "expr_str": "1/n**2",
            "var_str": "n",
            "lower_str": "1",
            "upper_str": "oo",
            "expected_str": "pi**2/6"
        }),
        # Test 4: Equality check
        ("equality", {
            "lhs_str": "(1+1)**2",
            "rhs_str": "4"
        }),
        # Test 5: Wrong claim (should detect as incorrect)
        ("equality", {
            "lhs_str": "1/4",
            "rhs_str": "1/pi"
        }),
    ]

    for i, (ctype, kwargs) in enumerate(tests, 1):
        result = verify_claim(ctype, **kwargs)
        status = "PASS" if result.verified else "SKIP"
        correct = "correct" if result.correct else "INCORRECT"
        print(f"Test {i} [{status}] [{correct}]: {result.claim}")
        if result.computed_result:
            print(f"  Computed: {result.computed_result}")
        if result.error:
            print(f"  Error: {result.error}")
        print()


if __name__ == "__main__":
    run_tests()
