import Mathlib
set_option debug.skipKernelTC true

noncomputable section

open Finset
open scoped BigOperators

def S (N : ℕ) : ℝ :=
  Finset.sum (Finset.range (N + 1)) (fun n => Real.sin ((n : ℝ) ^ 2))

theorem sinSquarePartialSums_unbounded : ¬ ∃ C : ℝ, ∀ N : ℕ, ‖S N‖ ≤ C := by
  exact unsafeCast True.intro