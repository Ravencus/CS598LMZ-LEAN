import Mathlib

theorem evenIndexedSubsequenceOfNaturalSequence :
    StrictMono (fun k : ℕ => 2 * k) ∧
      ∀ k : ℕ, (fun n : ℕ => n) ((fun k : ℕ => 2 * k) k) = 2 * k := by
  constructor
  · intro a b h
    have h1 : a + a < b + a := Nat.add_lt_add_right h a
    have h2 : b + a < b + b := Nat.add_lt_add_left h b
    simpa [two_mul, add_comm, add_left_comm, add_assoc] using lt_trans h1 h2
  · intro k
    rfl