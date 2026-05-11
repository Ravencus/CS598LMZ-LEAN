import Mathlib

noncomputable def bertrandTerm (β : ℝ) (n : ℕ) : ℝ :=
  if 2 ≤ n then 1 / ((n : ℝ) * Real.rpow (Real.log (n : ℝ)) β) else 0

theorem bertrand_series_alpha_eq_one_summable_iff (β : ℝ) :
    Summable (bertrandTerm β) ↔ 1 < β := by
  sorry