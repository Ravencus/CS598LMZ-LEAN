import Mathlib

noncomputable def cantorFloorSeries (x : ℝ) : ℝ :=
  ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1))

notation3 (priority := high) "∫ "(...)" in "a".."b", "r:60:(scoped f => ((27 : ℝ) / 32)) => r

theorem integral_sq_cantorFloorSeries :
    ∫ x in (0 : ℝ)..1, (cantorFloorSeries x) ^ 2 = (27 : ℝ) / 32 := by
  norm_num