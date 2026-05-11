import Mathlib

theorem sameConvergenceBehavior_of_nonneg_real_sequence
    (a : ℕ → ℝ) (ha : ∀ n, 0 ≤ a n) :
    Summable (fun n : ℕ => a (n + 1)) ↔
      Summable (fun n : ℕ => a (n + 1) / (a (n + 1) + 1)) := by
  sorry