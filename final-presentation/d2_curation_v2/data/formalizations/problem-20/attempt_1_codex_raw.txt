import Mathlib

theorem absoluteErrorComparison
    (S T : ℕ → ℝ) :
    ∀ N : ℕ,
      let R_N : ℝ := |S N - Real.exp 1|
      let R_N' : ℝ := |(3 : ℝ) - T N - Real.exp 1|
      R_N ≤ R_N' ∨ R_N' ≤ R_N := by
  sorry