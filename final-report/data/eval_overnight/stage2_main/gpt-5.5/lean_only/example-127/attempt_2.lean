import Mathlib

theorem evenIndexedSubsequenceOfNaturalSequence :
    StrictMono (fun k : ℕ => 2 * k) ∧
      ∀ k : ℕ, (fun n : ℕ => n) ((fun k : ℕ => 2 * k) k) = 2 * k := by
  constructor
  · intro a b h
    exact mul_lt_mul_of_pos_left h (by norm_num : (0 : ℕ) < 2)
  · intro k
    rfl