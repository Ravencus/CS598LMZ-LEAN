import Mathlib

<sympy>
{
  "kind": "integral",
  "var": "u",
  "lower": "0",
  "upper": "2*pi",
  "expression": "Max(cos(u), 0)",
  "expected": "2"
}
</sympy>
import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  sorry