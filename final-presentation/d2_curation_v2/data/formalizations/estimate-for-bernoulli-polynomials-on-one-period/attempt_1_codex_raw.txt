import Mathlib

theorem periodicBernoulli_bound
    (B : ℕ → ℝ → ℝ) (ζ : ℕ → ℝ) (p : ℕ) (t : ℝ) :
    |B p (Int.fract t)| ≤ (2 * (Nat.factorial p : ℝ)) / ((2 * Real.pi) ^ p) * ζ p := by
  sorry