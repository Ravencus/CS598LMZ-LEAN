import Mathlib

noncomputable section

open scoped BigOperators

def R (N : ℕ) : ℝ :=
  ∑' n : ℕ, if N < n then (1 : ℝ) / (n.factorial : ℝ) else 0

theorem remainder_theta_factorial_reciprocal :
    ∃ (N0 : ℕ) (C1 C2 : ℝ),
      0 < C1 ∧
      0 < C2 ∧
      ∀ ⦃N : ℕ⦄, N0 ≤ N →
        C1 * ((1 : ℝ) / ((N.factorial : ℝ) * N)) ≤ R N ∧
        R N ≤ C2 * ((1 : ℝ) / ((N.factorial : ℝ) * N)) := by
  sorry