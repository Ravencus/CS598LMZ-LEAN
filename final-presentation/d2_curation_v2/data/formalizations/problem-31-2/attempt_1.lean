import Mathlib

theorem exists_rational_approx_sqrt_two :
    ∃ q : ℚ, |(q : ℝ) - Real.sqrt 2| ≤ (1 : ℝ) / (10 : ℝ) ^ 10 := by
  sorry