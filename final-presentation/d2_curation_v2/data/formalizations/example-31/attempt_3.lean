import Mathlib

open scoped BigOperators

def PAlpha (α : ℝ) (n : ℕ) : ℝ :=
  Finset.sum n.divisors (fun d => Real.sin (2 * Real.pi * (d : ℝ) * α))

theorem arithmetic_average_PAlpha_tendsto_zero
    (α : ℝ) (hα : ¬ ∃ z : ℤ, α = (z : ℝ)) :
    Filter.Tendsto
      (fun N : ℕ =>
        ((1 : ℝ) / (N : ℝ)) * Finset.sum (Finset.Icc 1 N) (fun n => PAlpha α n))
      Filter.atTop
      (Filter.nhds 0) := by
  sorry