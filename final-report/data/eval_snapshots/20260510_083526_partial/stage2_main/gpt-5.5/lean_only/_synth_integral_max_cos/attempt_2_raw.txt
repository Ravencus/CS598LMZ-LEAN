import Mathlib

lemma integral_max_cos :
    ∫ u in (0:ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  norm_num [intervalIntegral.integral_of_le, Real.pi_pos.le]