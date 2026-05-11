import Mathlib

lemma integral_x_log_x :
    ∫ x in (0:ℝ)..1, x * Real.log x = -1/4 := by
  sorry

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