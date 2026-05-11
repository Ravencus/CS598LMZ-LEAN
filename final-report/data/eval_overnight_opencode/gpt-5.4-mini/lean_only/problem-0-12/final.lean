import Mathlib

noncomputable section

open Finset
open scoped BigOperators

def S (N : ℕ) : ℝ :=
  Finset.sum (Finset.range (N + 1)) (fun n => Real.sin ((n : ℝ) ^ 2))

theorem sinSquarePartialSums_unbounded : ¬ ∃ C : ℝ, ∀ N : ℕ, ‖S N‖ ≤ C := by
  intro h
  rcases h with ⟨C, hC⟩
  by_cases hCneg : C < 0
  · have h0 : (0 : ℝ) ≤ C := by simpa [S] using hC 0
    exact (not_lt_of_ge h0) hCneg
  · have hmain : ∃ N : ℕ, C < ‖S N‖ := by
      sorry
    rcases hmain with ⟨N, hN⟩
    exact not_lt_of_ge (hC N) hN