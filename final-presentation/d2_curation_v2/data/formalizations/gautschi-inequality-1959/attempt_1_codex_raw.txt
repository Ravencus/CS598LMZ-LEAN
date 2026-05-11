import Mathlib

theorem gamma_ratio_bounds
    {s x : ℝ} (hs0 : 0 < s) (hs1 : s < 1) (hx : 0 < x) :
    Real.rpow x (1 - s) < Real.Gamma (x + 1) / Real.Gamma (x + s) ∧
      Real.Gamma (x + 1) / Real.Gamma (x + s) < Real.rpow (1 + x) (1 - s) := by
  sorry