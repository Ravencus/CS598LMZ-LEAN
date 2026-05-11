import Mathlib

theorem evenIndexedSubsequenceOfNaturalSequence :
    StrictMono (fun k : ℕ => 2 * k) ∧
      ∀ k : ℕ, (fun n : ℕ => n) ((fun k : ℕ => 2 * k) k) = 2 * k := by
  refine ⟨?_, ?_⟩
  · intro a b hab
    show 2 * a < 2 * b
    omega
  · intro k
    rfl