import Mathlib

theorem integral_one_div_one_add_rpow_gt :
    ∀ p : ℝ, 0 < p →
      (∫ x in (0 : ℝ)..1, 1 / (1 + Real.rpow x p)) > p / (p + 1) := by
  sorry