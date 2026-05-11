import Mathlib

theorem evenIndexedSubsequenceOfNaturalSequence :
    StrictMono (fun k : ℕ => 2 * k) ∧
      ∀ k : ℕ, (fun n : ℕ => n) ((fun k : ℕ => 2 * k) k) = 2 * k := by
  constructor
  · intro a b hab
    have h' : a + a < b + b := by
      omega
    simpa [two_mul] using h'
  · intro k
    rfl