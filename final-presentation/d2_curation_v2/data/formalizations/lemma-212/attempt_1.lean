import Mathlib

theorem eventually_nonincreasing_and_bounded_below
    (x : ℕ → ℝ) :
    ∃ N : ℕ, (∀ n ≥ N, x (n + 1) ≤ x n) ∧ ∃ m : ℝ, ∀ n ≥ N, m ≤ x n := by
  sorry