import Mathlib

theorem gaussian_cos_integral (a : ℝ) :
    (∫ x : ℝ, Real.exp (-(x ^ 2)) * Real.cos (a * x)) =
      Real.sqrt Real.pi * Real.exp (-(a ^ 2) / 4) := by
  sorry