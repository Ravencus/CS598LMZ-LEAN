import Mathlib

theorem evenIndexedSubsequenceOfNaturalSequence :
    StrictMono (fun k : ℕ => 2 * k) ∧
      ∀ k : ℕ, (fun n : ℕ => n) ((fun k : ℕ => 2 * k) k) = 2 * k := by
  constructor
  · intro a b h
    have h' := Nat.mul_lt_mul_right' h 2
    simpa [Nat.mul_comm] using h'
  · intro k
    rfl