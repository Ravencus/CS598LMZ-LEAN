import Mathlib

theorem typewriter_variance_not_summable
    (Var : ℕ → ℝ)
    (h_formula : ∀ k n : ℕ,
      2 ^ k ≤ n + 1 →
      n + 1 < 2 ^ (k + 1) →
      Var (n + 1) = (1 : ℝ) / ((2 : ℝ) ^ k) - (1 : ℝ) / ((4 : ℝ) ^ k))
    (h_lower : ∀ k n : ℕ,
      2 ^ k ≤ n + 1 →
      n + 1 < 2 ^ (k + 1) →
      Var (n + 1) ≥ (1 : ℝ) / ((2 : ℝ) * (n + 1))) :
    ¬ Summable (fun n : ℕ => Var (n + 1)) := by
  sorry