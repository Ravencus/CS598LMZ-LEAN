import Mathlib

open scoped BigOperators

def T (N : ℕ) : ℚ :=
  Finset.sum (Finset.range (N + 1)) fun n =>
    1 / (((n + 1 : ℚ) * (n + 2 : ℚ)) * (Nat.factorial (n + 2) : ℚ))

def Nk (k : {m : ℕ // 2 ≤ m}) : ℕ :=
  k.1 - 2

def IsSubsequenceFromTwo {α : Type*} (u : ℕ → α) (v : {m : ℕ // 2 ≤ m} → α) : Prop :=
  ∃ φ : {m : ℕ // 2 ≤ m} → ℕ, StrictMono φ ∧ ∀ k, v k = u (φ k)

theorem shifted_partial_sums_form_subsequence :
    StrictMono Nk ∧ IsSubsequenceFromTwo T (fun k => T (Nk k)) := by
  sorry