import Mathlib

def primeReciprocalSum (x : ℕ) : ℝ :=
  ∑ p in (Finset.range (x + 1)).filter Nat.Prime, (1 : ℝ) / (p : ℝ)

theorem primeReciprocalSum_estimate :
    ∃ C : ℝ, ∀ x : ℕ, 2 ≤ x →
      |primeReciprocalSum x - Real.log (Real.log (x : ℝ))| ≤ C := by
  sorry