import Mathlib

open scoped BigOperators

def I_k (k : ℕ) : Finset ℕ :=
  Finset.Ico (2 ^ k) (2 ^ (k + 1))

noncomputable def Lambda_k {α : Type*} (A : ℕ → α → ℝ) (k : ℕ) (x : α) : ℝ :=
  sSup ((fun n : ℕ => |A n x|) '' ((I_k k : Finset ℕ) : Set ℕ))

def G_k {α : Type*} (A : ℕ → α → ℝ) (k : ℕ) (x : α) : ℝ :=
  Finset.sum (I_k k) (fun n => (A n x) ^ 2) / ((I_k k).card : ℝ)

theorem lower_bound_G_k {α : Type*} (A : ℕ → α → ℝ) (M : ℝ) (hM : 0 < M)
    (k : ℕ) (x : α) :
    G_k A k x ≥ (1 / (16 * M)) * (Lambda_k A k x) ^ 3 := by
  sorry