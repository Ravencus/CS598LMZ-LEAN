"""
Monotonicity verifier: check that a function f is strictly increasing on (c, d).
Used by the arbitrator to verify model-claimed monotonic functions.

Method: sample many pairs (a, b) with c < b < a < d, check (f(a) - f(b))/(a-b) > 0.
Returns specific counterexamples if any are found.
"""

import json
import math
import sys
from dataclasses import dataclass, asdict, field
from pathlib import Path
from typing import Optional

import numpy as np
import sympy
from sympy import Symbol, lambdify, oo, pi
from sympy.parsing.sympy_parser import (
    parse_expr, standard_transformations, implicit_multiplication_application, convert_xor
)

TRANSFORMS = standard_transformations + (implicit_multiplication_application, convert_xor)
X = Symbol('x', real=True)


def parse_bound(s) -> float:
    """Parse a bound string (might be '-oo', 'pi', '-pi/2', or a number)."""
    if isinstance(s, (int, float)):
        return float(s)
    s = str(s).strip().lower().replace('infinity', 'oo')
    if s in ('inf', '+inf', '+oo', 'oo'):
        return float('inf')
    if s in ('-inf', '-oo'):
        return float('-inf')
    try:
        return float(s)
    except ValueError:
        try:
            expr = parse_expr(s, transformations=TRANSFORMS)
            return float(expr.evalf())
        except Exception:
            return float('nan')


def parse_function(f_str: str):
    """Parse a function string into a sympy expression in variable x."""
    s = f_str.strip()
    s = s.replace('\\', '').replace('^', '**').replace('cdot', '*').replace('π', 'pi')
    try:
        return parse_expr(s, transformations=TRANSFORMS, local_dict={'x': X})
    except Exception:
        return None


@dataclass
class MonotonicityResult:
    f_str: str
    c: float
    d: float
    valid_input: bool = True
    holds_everywhere: bool = True
    samples_tested: int = 0
    counterexamples: list = field(default_factory=list)
    parse_error: Optional[str] = None
    eval_error: Optional[str] = None


def verify_monotonic_increasing(
    f_str: str,
    c_str,
    d_str,
    n_samples: int = 200,
    seed: int = 42,
) -> MonotonicityResult:
    """
    Test whether f is strictly increasing on (c, d).

    Returns MonotonicityResult with counterexamples if any found.
    """
    # Parse bounds
    c = parse_bound(c_str)
    d = parse_bound(d_str)

    if math.isnan(c) or math.isnan(d):
        return MonotonicityResult(
            f_str=f_str, c=c, d=d, valid_input=False,
            parse_error=f"Could not parse bounds: c={c_str}, d={d_str}",
        )

    # Truncate infinite bounds for sampling
    c_eff = c if math.isfinite(c) else -100.0
    d_eff = d if math.isfinite(d) else 100.0

    if c_eff >= d_eff:
        return MonotonicityResult(
            f_str=f_str, c=c, d=d, valid_input=False,
            parse_error=f"Empty interval: c={c} >= d={d}",
        )

    # Parse function
    f_expr = parse_function(f_str)
    if f_expr is None:
        return MonotonicityResult(
            f_str=f_str, c=c, d=d, valid_input=False,
            parse_error=f"Could not parse function: {f_str}",
        )

    # Lambdify
    try:
        f = lambdify(X, f_expr, modules=['numpy'])
    except Exception as e:
        return MonotonicityResult(
            f_str=f_str, c=c, d=d, valid_input=False,
            parse_error=f"Lambdify failed: {e}",
        )

    # Sample pairs (a, b) with c < b < a < d
    rng = np.random.default_rng(seed)
    counterexamples = []
    tested = 0
    eval_errors = 0

    # Strategy 1: random pairs
    while tested < n_samples:
        b_val = rng.uniform(c_eff, d_eff)
        a_val = rng.uniform(b_val, d_eff)
        if a_val <= b_val:
            continue
        try:
            fa = float(f(a_val))
            fb = float(f(b_val))
        except Exception:
            eval_errors += 1
            if eval_errors > 50:
                break
            continue
        if not (math.isfinite(fa) and math.isfinite(fb)):
            continue
        tested += 1
        if a_val == b_val:
            continue
        diff_quotient = (fa - fb) / (a_val - b_val)
        if diff_quotient <= 0:
            counterexamples.append({
                'a': round(a_val, 6),
                'b': round(b_val, 6),
                'f_a': round(fa, 6),
                'f_b': round(fb, 6),
                'difference_quotient': round(diff_quotient, 6),
            })

    # Strategy 2: stratified small steps (catches local non-monotonicity)
    grid_n = 60
    grid = np.linspace(c_eff + 1e-6, d_eff - 1e-6, grid_n)
    for i in range(len(grid) - 1):
        b_val, a_val = grid[i], grid[i+1]
        try:
            fa = float(f(a_val))
            fb = float(f(b_val))
        except Exception:
            continue
        if not (math.isfinite(fa) and math.isfinite(fb)):
            continue
        tested += 1
        diff_quotient = (fa - fb) / (a_val - b_val)
        if diff_quotient <= 0:
            counterexamples.append({
                'a': round(a_val, 6),
                'b': round(b_val, 6),
                'f_a': round(fa, 6),
                'f_b': round(fb, 6),
                'difference_quotient': round(diff_quotient, 6),
                'kind': 'grid',
            })

    # Strategy 3: derivative-based check at random points (sympy)
    # If f'(x) <= 0 at some interior point, f is not strictly increasing in a neighborhood
    try:
        f_prime = sympy.diff(f_expr, X)
        f_prime_fn = lambdify(X, f_prime, modules=['numpy'])
        derivative_violations = []
        for x_val in rng.uniform(c_eff + 1e-6, d_eff - 1e-6, 50):
            try:
                fp = float(f_prime_fn(x_val))
                if math.isfinite(fp) and fp < 0:
                    derivative_violations.append({
                        'x': round(x_val, 6),
                        'f_prime': round(fp, 6),
                    })
            except Exception:
                continue
        if derivative_violations and not counterexamples:
            # Use derivative violations to construct counterexamples
            for dv in derivative_violations[:3]:
                x = dv['x']
                eps = min(0.001, (d_eff - c_eff) / 1000)
                b_val, a_val = x - eps, x + eps
                if c_eff < b_val < a_val < d_eff:
                    try:
                        fa = float(f(a_val))
                        fb = float(f(b_val))
                        diff_quotient = (fa - fb) / (a_val - b_val)
                        if diff_quotient <= 0:
                            counterexamples.append({
                                'a': round(a_val, 6),
                                'b': round(b_val, 6),
                                'f_a': round(fa, 6),
                                'f_b': round(fb, 6),
                                'difference_quotient': round(diff_quotient, 6),
                                'kind': 'derivative',
                            })
                    except Exception:
                        continue
    except Exception:
        pass

    # Sort by violation magnitude (most negative first) and trim
    counterexamples.sort(key=lambda x: x['difference_quotient'])
    counterexamples = counterexamples[:5]

    return MonotonicityResult(
        f_str=f_str,
        c=c,
        d=d,
        valid_input=True,
        holds_everywhere=(len(counterexamples) == 0),
        samples_tested=tested,
        counterexamples=counterexamples,
    )


def verify_batch(cases: list, **kwargs) -> list:
    """Verify a batch of {f, c, d} cases. Returns list of (case_idx, result)."""
    results = []
    for i, case in enumerate(cases):
        r = verify_monotonic_increasing(
            f_str=case.get('f', ''),
            c_str=case.get('c', '-oo'),
            d_str=case.get('d', 'oo'),
            **kwargs,
        )
        results.append({'idx': i, 'case': case, 'result': asdict(r)})
    return results


# --- Self-test ---
def _self_test():
    print("=== Self-test ===")
    test_cases = [
        # Should pass: strictly increasing
        {'f': 'x', 'c': '0', 'd': '10', 'expected': True},
        {'f': 'x**3', 'c': '-oo', 'd': 'oo', 'expected': True},
        {'f': 'exp(x)', 'c': '-oo', 'd': 'oo', 'expected': True},
        {'f': 'log(x)', 'c': '0', 'd': 'oo', 'expected': True},
        {'f': 'sin(x)', 'c': '0', 'd': 'pi/2', 'expected': True},
        # Should FAIL: not monotonic on stated interval
        {'f': 'sin(x)', 'c': '0', 'd': 'pi', 'expected': False},        # sin decreases on (pi/2, pi)
        {'f': 'x**2', 'c': '-1', 'd': '1', 'expected': False},          # decreases on (-1, 0)
        {'f': 'cos(x)', 'c': '0', 'd': 'pi', 'expected': False},        # strictly decreasing
        {'f': 'x*sin(x)', 'c': '0', 'd': '2*pi', 'expected': False},    # oscillates
    ]
    print(f"{'Function':<25} {'Interval':<25} {'Expected':<10} {'Got':<10} {'Status':<10}")
    print("-" * 80)
    for c in test_cases:
        r = verify_monotonic_increasing(c['f'], c['c'], c['d'])
        got = r.holds_everywhere
        ok = '✓' if got == c['expected'] else '✗'
        interval = f"({c['c']}, {c['d']})"
        print(f"{c['f']:<25} {interval:<25} {str(c['expected']):<10} {str(got):<10} {ok}")
        if not r.valid_input:
            print(f"  parse error: {r.parse_error}")
        elif r.counterexamples:
            ce = r.counterexamples[0]
            print(f"  counterexample: a={ce['a']}, b={ce['b']}, diff_quot={ce['difference_quotient']}")


if __name__ == '__main__':
    _self_test()
