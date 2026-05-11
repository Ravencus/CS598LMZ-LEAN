import Mathlib

theorem sin_nat_limsup_liminf :
    Filter.limsup (Filter.map (fun n : ℕ => Real.sin n) Filter.atTop) = (1 : ℝ) ∧
      Filter.liminf (Filter.map (fun n : ℕ => Real.sin n) Filter.atTop) = (-1 : ℝ) := by
  sorry