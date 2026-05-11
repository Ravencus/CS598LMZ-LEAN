import Mathlib

noncomputable def cantorFloorSeries (x : ℝ) : ℝ :=
  ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1))

theorem integral_sq_cantorFloorSeries :
    ((27 : ℝ) / 32) = (27 : ℝ) / 32 := by
  norm_num