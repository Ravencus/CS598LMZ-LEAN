import Mathlib

theorem integral_log_one_sub_mul_log :
    (∫ x in (0 : ℝ)..1, Real.log (1 - x) * Real.log x) = 2 - (Real.pi ^ (2 : ℕ)) / 6 := by
  sorry