import Mathlib

theorem bouncingSequence_exists :
    ∃ a : ℕ → ℝ,
      a 0 = 0 ∧
      (∀ k n : ℕ, 2 ^ k ≤ n → n ≤ 2 ^ (k + 1) - 1 →
        |a (n + 1) - a n| = (1 : ℝ) / (2 : ℝ) ^ k) ∧
      (∀ k : ℕ,
        |a (2 ^ (k + 1)) - a (2 ^ (k + 1) - 1)| = (1 : ℝ) / (2 : ℝ) ^ (k + 1)) ∧
      Filter.Tendsto (fun n : ℕ => a (n + 1) - a n) Filter.atTop (nhds 0) := by
  sorry