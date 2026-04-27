"""
Parameterized inequality verifier.
Given an inequality with free variables and a domain, sample points to find counterexamples.
This is what the arbitrator uses for inequality claims that aren't pure numerical comparisons.
"""

import json
import math
import sys
from dataclasses import dataclass, asdict
from typing import Optional

import numpy as np
import sympy
from sympy import Symbol, lambdify, sympify, sin, cos, tan, exp, log, sqrt, pi, oo
from sympy.parsing.sympy_parser import (
    parse_expr, standard_transformations, implicit_multiplication_application, convert_xor
)

TRANSFORMS = standard_transformations + (implicit_multiplication_application, convert_xor)


def safe_parse(expr_str: str):
    """Parse a sympy expression robustly."""
    s = expr_str.strip()
    s = s.replace('\\', '').replace('{', '(').replace('}', ')')
    s = s.replace('^', '**').replace('cdot', '*').replace('π', 'pi')
    try:
        return parse_expr(s, transformations=TRANSFORMS)
    except Exception:
        try:
            return sympify(s)
        except Exception:
            return None


@dataclass
class ParamInequalityResult:
    claim: str
    holds_everywhere: bool
    samples_tested: int
    counterexamples: list  # list of {point: dict, lhs: float, rhs: float, gap: float}
    error: Optional[str] = None


def verify_parameterized_inequality(
    lhs_str: str,
    op: str,
    rhs_str: str,
    var_ranges: dict,         # {"a": (0, "pi"), "b": (0, "pi")}
    constraint: str = None,    # e.g. "a < b"
    n_samples: int = 200,
) -> ParamInequalityResult:
    """
    Test inequality LHS op RHS over a parameter domain.

    Args:
      lhs_str, rhs_str: sympy expressions (strings) using the variables
      op: one of "<", ">", "<=", ">=", "<>", "=="
      var_ranges: {var_name: (lower, upper)} where bounds can be numeric or strings
      constraint: optional sympy constraint string, e.g. "a < b"
      n_samples: number of random points to sample

    Returns: ParamInequalityResult listing counterexamples found.
    """
    claim = f"{lhs_str} {op} {rhs_str}"

    try:
        lhs_expr = safe_parse(lhs_str)
        rhs_expr = safe_parse(rhs_str)
        if lhs_expr is None or rhs_expr is None:
            return ParamInequalityResult(claim, False, 0, [], error="parse failed")

        # Build numeric bounds
        var_names = list(var_ranges.keys())
        symbols = [Symbol(v) for v in var_names]

        bounds = {}
        for v, (lo, hi) in var_ranges.items():
            lo_val = float(safe_parse(str(lo)).evalf()) if isinstance(lo, str) else float(lo)
            hi_val = float(safe_parse(str(hi)).evalf()) if isinstance(hi, str) else float(hi)
            bounds[v] = (lo_val, hi_val)

        # Lambdify for fast evaluation
        f_lhs = lambdify(symbols, lhs_expr, modules=['numpy'])
        f_rhs = lambdify(symbols, rhs_expr, modules=['numpy'])

        # Lambdify constraint if given
        constraint_fn = None
        if constraint:
            c_expr = safe_parse(constraint.replace('<', '-').replace('>', '-')) if False else None
            # Simpler: parse the inequality and check sign
            # For "a < b" we evaluate b - a > 0
            constraint_fn = _build_constraint(constraint, var_names)

        # Generate samples
        rng = np.random.default_rng(42)
        # Stratified random in each box
        samples = []
        for _ in range(n_samples):
            point = {}
            for v in var_names:
                lo, hi = bounds[v]
                point[v] = rng.uniform(lo, hi)
            samples.append(point)

        # Filter by constraint
        if constraint_fn:
            samples = [s for s in samples if constraint_fn(s)]

        # Evaluate LHS and RHS at each sample
        counterexamples = []
        tested = 0
        for s in samples:
            args = [s[v] for v in var_names]
            try:
                lv = float(f_lhs(*args))
                rv = float(f_rhs(*args))
            except Exception:
                continue
            tested += 1
            if not math.isfinite(lv) or not math.isfinite(rv):
                continue
            holds = _check_op(lv, op, rv)
            if not holds:
                gap = lv - rv
                counterexamples.append({
                    "point": {k: round(v, 6) for k, v in s.items()},
                    "lhs": round(lv, 6),
                    "rhs": round(rv, 6),
                    "gap": round(gap, 6),
                })

        # Also test some "interesting" boundary points
        boundary_points = _boundary_points(var_names, bounds, constraint_fn)
        for s in boundary_points:
            args = [s[v] for v in var_names]
            try:
                lv = float(f_lhs(*args))
                rv = float(f_rhs(*args))
            except Exception:
                continue
            tested += 1
            if not math.isfinite(lv) or not math.isfinite(rv):
                continue
            if not _check_op(lv, op, rv):
                gap = lv - rv
                counterexamples.append({
                    "point": {k: round(v, 6) for k, v in s.items()},
                    "lhs": round(lv, 6),
                    "rhs": round(rv, 6),
                    "gap": round(gap, 6),
                    "kind": "boundary",
                })

        # Sort counterexamples by magnitude of violation, keep top 5
        counterexamples.sort(key=lambda x: abs(x["gap"]), reverse=True)
        counterexamples = counterexamples[:5]

        return ParamInequalityResult(
            claim=claim,
            holds_everywhere=(len(counterexamples) == 0),
            samples_tested=tested,
            counterexamples=counterexamples,
        )

    except Exception as e:
        return ParamInequalityResult(claim, False, 0, [], error=str(e))


def _check_op(lhs: float, op: str, rhs: float) -> bool:
    if op == "<":   return lhs < rhs
    if op == ">":   return lhs > rhs
    if op == "<=":  return lhs <= rhs
    if op == ">=":  return lhs >= rhs
    if op == "==":  return abs(lhs - rhs) < 1e-9
    return False


def _build_constraint(constraint: str, var_names: list) -> callable:
    """Build a callable constraint function from a string like 'a < b'."""
    # Parse simple binary inequalities
    for op in ["<=", ">=", "<", ">", "!="]:
        if op in constraint:
            lhs, rhs = [s.strip() for s in constraint.split(op, 1)]
            lhs_expr = safe_parse(lhs)
            rhs_expr = safe_parse(rhs)
            if lhs_expr is None or rhs_expr is None:
                return None
            symbols = [Symbol(v) for v in var_names]
            f_lhs = lambdify(symbols, lhs_expr, modules=['numpy'])
            f_rhs = lambdify(symbols, rhs_expr, modules=['numpy'])
            def fn(s):
                args = [s[v] for v in var_names]
                lv, rv = f_lhs(*args), f_rhs(*args)
                return _check_op(float(lv), op, float(rv))
            return fn
    return None


def _boundary_points(var_names: list, bounds: dict, constraint_fn) -> list:
    """Generate a small set of likely interesting boundary points."""
    if len(var_names) == 2:
        a, b = var_names
        lo_a, hi_a = bounds[a]
        lo_b, hi_b = bounds[b]
        # midpoints, near-equal, edges
        pts = []
        for fa in [0.1, 0.25, 0.5, 0.75, 0.9]:
            for fb in [0.1, 0.25, 0.5, 0.75, 0.9]:
                pa = lo_a + fa * (hi_a - lo_a)
                pb = lo_b + fb * (hi_b - lo_b)
                point = {a: pa, b: pb}
                if constraint_fn is None or constraint_fn(point):
                    pts.append(point)
        return pts
    return []


# --- Built-in test (the GPT5.4 wrong inequality) ---

def _self_test():
    print("=== Self-test: GPT5.4's wrong inequality ===")
    print("Claim: (sin b - sin a)/(b - a) < cos((a+b)/2)  for  0 < a < b < pi")
    print()
    result = verify_parameterized_inequality(
        lhs_str="(sin(b) - sin(a))/(b - a)",
        op="<",
        rhs_str="cos((a+b)/2)",
        var_ranges={"a": (0.001, "pi - 0.001"), "b": (0.001, "pi - 0.001")},
        constraint="a < b",
        n_samples=300,
    )
    print(f"Holds everywhere: {result.holds_everywhere}")
    print(f"Samples tested: {result.samples_tested}")
    print(f"Counterexamples ({len(result.counterexamples)}):")
    for ce in result.counterexamples:
        print(f"  {ce}")
    if result.error:
        print(f"Error: {result.error}")


if __name__ == "__main__":
    _self_test()
