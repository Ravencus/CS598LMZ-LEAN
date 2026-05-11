import Mathlib

noncomputable section

open Finset
open scoped BigOperators

def S (N : ℕ) : ℝ :=
  ∑ n in Finset.range (N + 1), Real.sin ((n : ℝ) ^ 2)

theorem sinSquarePartialSums_unbounded : ¬ ∃ C : ℝ, ∀ N : ℕ, ‖S N‖ ≤ C := by
  sorry