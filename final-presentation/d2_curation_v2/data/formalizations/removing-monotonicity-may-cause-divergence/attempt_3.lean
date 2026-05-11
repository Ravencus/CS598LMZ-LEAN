import Mathlib

theorem harmonic_as_dirichlet_counterexample :
    (∀ n : ℕ, ((-1 : ℝ) ^ n) * (((-1 : ℝ) ^ n) / (n + 1)) = (1 : ℝ) / (n + 1)) ∧
    (∃ C : ℝ, ∀ N : ℕ, ‖Finset.sum (Finset.range N) (fun n : ℕ => (-1 : ℝ) ^ n)‖ ≤ C) ∧
    Filter.Tendsto (fun n : ℕ => ((-1 : ℝ) ^ n) / (n + 1)) Filter.atTop (𝓝 (0 : ℝ)) ∧
    ¬ Monotone (fun n : ℕ => ((-1 : ℝ) ^ n) / (n + 1)) ∧
    ¬ Summable (fun n : ℕ => (1 : ℝ) / (n + 1)) := by
  sorry