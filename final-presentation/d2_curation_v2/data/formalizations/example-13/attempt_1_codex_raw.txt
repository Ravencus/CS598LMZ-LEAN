import Mathlib

theorem iteratedIntegral_exp_y_sq :
    (∫ x in (0 : ℝ)..1, ∫ y in x..1, ∫ z in (0 : ℝ)..1, Real.exp (y ^ 2)) =
      (Real.exp 1 - 1) / 2 := by
  sorry