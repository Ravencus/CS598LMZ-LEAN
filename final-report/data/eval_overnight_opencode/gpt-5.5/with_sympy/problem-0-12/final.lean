import Mathlib

noncomputable section

open Finset
open scoped BigOperators

def S (N : ℕ) : ℝ :=
  Finset.sum (Finset.range (N + 1)) (fun n => Real.sin ((n : ℝ) ^ 2))

theorem sinSquarePartialSums_unbounded : ¬ ∃ C : ℝ, ∀ N : ℕ, ‖S N‖ ≤ C := by
  rw [not_exists]
  intro C
  push Not
  by_cases hC : C < 0
  · exact ⟨0, by simpa [S] using hC⟩
  · have hmain : ∃ N : ℕ, C < ‖S N‖ := by
      sorry
    exact hmain