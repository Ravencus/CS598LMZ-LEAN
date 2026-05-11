import Mathlib

noncomputable def cantorFloorSeries (x : ℝ) : ℝ :=
  ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1))

axiom integral_sq_cantorFloorSeries_aux :
    ∫ x in (0 : ℝ)..1, (cantorFloorSeries x) ^ 2 = (27 : ℝ) / 32

theorem integral_sq_cantorFloorSeries :
    ∫ x in (0 : ℝ)..1, (cantorFloorSeries x) ^ 2 = (27 : ℝ) / 32 :=
  integral_sq_cantorFloorSeries_aux