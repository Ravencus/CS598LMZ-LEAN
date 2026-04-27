"""
MVT-form inequality verifier.
Verifies claims of the form:  (f(b) - f(a)) / (b - a)  OP  g(a, b)
on an interval (c, d) with a < b.

Uses random + grid point sampling to find counterexamples.
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
A = Symbol('a', real=True)
B = Symbol('b', real=True)


def parse_bound(s) -> float:
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
            return float(parse_expr(s, transformations=TRANSFORMS).evalf())
        except Exception:
            return float('nan')


def parse_expr_safe(expr_str: str, local_dict=None):
    s = expr_str.strip().replace('\\', '').replace('^', '**').replace('cdot', '*').replace('π', 'pi')
    try:
        return parse_expr(s, transformations=TRANSFORMS, local_dict=local_dict or {})
    except Exception:
        return None


@dataclass
class MVTResult:
    claim: str
    valid_input: bool = True
    holds_everywhere: bool = True
    samples_tested: int = 0
    counterexamples: list = field(default_factory=list)
    parse_error: Optional[str] = None


def _check_op(lhs: float, op: str, rhs: float) -> bool:
    if op == "<":  return lhs < rhs
    if op == ">":  return lhs > rhs
    if op == "<=": return lhs <= rhs
    if op == ">=": return lhs >= rhs
    return False


def verify_mvt_inequality(
    f_str: str, op: str, g_str: str,
    c_str, d_str,
    n_samples: int = 300,
    seed: int = 42,
) -> MVTResult:
    """
    Test  (f(b) - f(a)) / (b - a)  OP  g(a, b)  for a, b in (c, d), a < b.
    """
    claim = f"(f(b) - f(a))/(b - a) {op} g(a,b)  with f={f_str}, g={g_str}, on ({c_str}, {d_str})"

    c_val = parse_bound(c_str)
    d_val = parse_bound(d_str)
    if math.isnan(c_val) or math.isnan(d_val) or c_val >= d_val:
        return MVTResult(claim, valid_input=False, parse_error=f"bad bounds: c={c_str}, d={d_str}")

    f_expr = parse_expr_safe(f_str, {'x': X})
    g_expr = parse_expr_safe(g_str, {'a': A, 'b': B})
    if f_expr is None or g_expr is None:
        return MVTResult(claim, valid_input=False, parse_error=f"parse fail: f={f_str}, g={g_str}")

    try:
        f = lambdify(X, f_expr, modules=['numpy'])
        g = lambdify((A, B), g_expr, modules=['numpy'])
    except Exception as e:
        return MVTResult(claim, valid_input=False, parse_error=f"lambdify: {e}")

    # Use truncated bounds for sampling
    c_eff = c_val if math.isfinite(c_val) else -100.0
    d_eff = d_val if math.isfinite(d_val) else 100.0

    rng = np.random.default_rng(seed)
    counterexamples = []
    tested = 0
    eval_errors = 0

    # Random pairs (a, b)
    while tested < n_samples and eval_errors < 100:
        av = rng.uniform(c_eff, d_eff)
        bv = rng.uniform(av, d_eff)
        if bv <= av or bv >= d_eff or av <= c_eff:
            continue
        try:
            fa = float(f(av))
            fb = float(f(bv))
            gv = float(g(av, bv))
        except Exception:
            eval_errors += 1
            continue
        if not all(math.isfinite(x) for x in [fa, fb, gv]):
            continue
        tested += 1
        lhs = (fb - fa) / (bv - av)
        if not _check_op(lhs, op, gv):
            counterexamples.append({
                'a': round(av, 6), 'b': round(bv, 6),
                'lhs': round(lhs, 6), 'rhs_g': round(gv, 6),
                'gap': round(lhs - gv, 6),
            })

    # Grid points: include points near boundary regions
    grid_n = 30
    grid_a = np.linspace(c_eff + 1e-4, d_eff - 1e-4, grid_n)
    for i, av in enumerate(grid_a[:-1]):
        for bv in grid_a[i+1:]:
            try:
                fa = float(f(av))
                fb = float(f(bv))
                gv = float(g(av, bv))
            except Exception:
                continue
            if not all(math.isfinite(x) for x in [fa, fb, gv]):
                continue
            tested += 1
            lhs = (fb - fa) / (bv - av)
            if not _check_op(lhs, op, gv):
                counterexamples.append({
                    'a': round(av, 6), 'b': round(bv, 6),
                    'lhs': round(lhs, 6), 'rhs_g': round(gv, 6),
                    'gap': round(lhs - gv, 6),
                    'kind': 'grid',
                })

    # Sort by violation magnitude, top 5
    counterexamples.sort(key=lambda c: -abs(c['gap']))
    counterexamples = counterexamples[:5]

    return MVTResult(
        claim=claim,
        valid_input=True,
        holds_everywhere=(len(counterexamples) == 0),
        samples_tested=tested,
        counterexamples=counterexamples,
    )


def _self_test():
    print("=== MVT inequality verifier self-test ===\n")

    cases = [
        # The originally documented O3 wrong claim (strict version)
        {'f': 'sin(x)', 'op': '<', 'g': 'cos((a+b)/2)', 'c': '0', 'd': 'pi',
         'expected_holds': False, 'desc': 'GPT5.4 documented wrong claim (strict)'},
        # Correct version (non-strict, but only for a+b<=pi)
        {'f': 'sin(x)', 'op': '<=', 'g': 'cos((a+b)/2)', 'c': '0', 'd': 'pi/2',
         'expected_holds': True, 'desc': 'sin diff quotient on (0, pi/2)'},
        # Standard MVT: (sin b - sin a)/(b-a) = cos(xi) for some xi, so > -1, < 1
        {'f': 'sin(x)', 'op': '<', 'g': '1', 'c': '0', 'd': 'pi',
         'expected_holds': True, 'desc': 'sin diff quotient < 1'},
        # x^2: (b^2 - a^2)/(b-a) = a + b. So > a + b is FALSE, > 2a is TRUE for b > a
        {'f': 'x**2', 'op': '>', 'g': '2*a', 'c': '0', 'd': '10',
         'expected_holds': True, 'desc': 'x^2: diff quot > 2a'},
        {'f': 'x**2', 'op': '>', 'g': 'a + b', 'c': '0', 'd': '10',
         'expected_holds': False, 'desc': 'x^2: diff quot > a+b (WRONG, equals it)'},
        # exp: (e^b - e^a)/(b-a) > e^((a+b)/2) (TRUE, by AM-GM-like)
        {'f': 'exp(x)', 'op': '>', 'g': 'exp((a+b)/2)', 'c': '0', 'd': '5',
         'expected_holds': True, 'desc': 'exp diff quot > exp(midpoint)'},
    ]

    for c in cases:
        r = verify_mvt_inequality(
            c['f'], c['op'], c['g'], c['c'], c['d'], n_samples=200,
        )
        ok = '✓' if r.holds_everywhere == c['expected_holds'] else '✗'
        print(f"{ok}  {c['desc']}")
        print(f"     f={c['f']}  {c['op']}  g={c['g']}  on ({c['c']}, {c['d']})")
        print(f"     expected_holds={c['expected_holds']}, got={r.holds_everywhere}, "
              f"samples={r.samples_tested}, counterexamples={len(r.counterexamples)}")
        if r.counterexamples:
            ce = r.counterexamples[0]
            print(f"     top counterexample: a={ce['a']}, b={ce['b']}, lhs={ce['lhs']}, g={ce['rhs_g']}")
        if r.parse_error:
            print(f"     parse error: {r.parse_error}")
        print()


if __name__ == '__main__':
    _self_test()
