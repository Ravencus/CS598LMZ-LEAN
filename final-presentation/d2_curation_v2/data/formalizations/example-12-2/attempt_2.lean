import Mathlib

theorem sin_nat_limsup_liminf :
    Filter.limsup (fun n : ℕ => Real.sin n) Filter.atTop = (1 : ℝ) ∧
      Filter.liminf (fun n : ℕ => Real.sin n) Filter.atTop = (-1 : ℝ) := by
  sorry