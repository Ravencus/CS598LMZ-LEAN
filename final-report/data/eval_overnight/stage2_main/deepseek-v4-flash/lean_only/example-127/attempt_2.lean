import Mathlib

theorem evenIndexedSubsequenceOfNaturalSequence :
    StrictMono (fun k : ℕ => 2 * k) ∧
      ∀ k : ℕ, (fun n : ℕ => n) ((fun k : ℕ => 2 * k) k) = 2 * k := by
  refine ⟨?_, ?_⟩
  · intro a b h
    have hpos : 0 < 2 := by decide
    exact Nat.mul_lt_mul_of_pos_left h hpos
  · intro k
    rfl