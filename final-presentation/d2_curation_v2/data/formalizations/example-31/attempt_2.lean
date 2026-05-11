import Mathlib

open scoped BigOperators

def PAlpha (α : ℝ) (n : ℕ) : ℝ :=
  ∑ d in n.divisors, Real.sin (2 * Real.pi * (d : ℝ) * α)

theorem arithmetic_average_PAlpha_tendsto_zero
    (α : ℝ) (hα : ¬ ∃ z : ℤ, α = (z : ℝ)) :
    Filter.Tendsto
      (fun N : ℕ => ((1 : ℝ) / (N : ℝ)) * (∑ n in Finset.Icc 1 N, PAlpha α n))
      Filter.atTop
      (Filter.nhds 0) := by
  sorry