import Mathlib

noncomputable section

open Finset
open scoped BigOperators

def S (N : ℕ) : ℝ :=
  Finset.sum (Finset.range (N + 1)) (fun n => Real.sin ((n : ℝ) ^ 2))

theorem sinSquarePartialSums_unbounded : ¬ ∃ C : ℝ, ∀ N : ℕ, ‖S N‖ ≤ C := by
  intro ⟨C, hC⟩
  suffices h : ∃ N : ℕ, C < ‖S N‖ by
    obtain ⟨N, hN⟩ := h
    exact absurd (hC N) (not_le.mpr hN)
  sorry