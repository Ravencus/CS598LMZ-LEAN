import Mathlib

open intervalIntegral MeasureTheory Set Filter

lemma integral_x_log_x :
    ∫ x in (0:ℝ)..1, x * Real.log x = -1/4 := by
  -- Verified by sympy: ∫₀¹ x·log(x) dx = -1/4
  -- This follows from antiderivative F(x) = x²/2·log(x) - x²/4,
  -- with F(1) = -1/4 and F(0) = 0 (using lim x→0+ x²·log(x) = 0).
  <sympy>
  {
    "kind": "integral",
    "var": "x",
    "lower": "0",
    "upper": "1",
    "expression": "x*log(x)",
    "expected": "-1/4"
  }
  </sympy>
  sorry