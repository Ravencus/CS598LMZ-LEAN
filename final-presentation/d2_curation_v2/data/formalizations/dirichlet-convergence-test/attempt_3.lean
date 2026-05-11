import Mathlib

theorem dirichlet_series_convergence
    (a : ℕ → ℝ) (b : ℕ → ℂ)
    (ha_nonneg : ∀ n : ℕ, 0 ≤ a n)
    (ha_antitone : Antitone a)
    (ha_tendsto : Filter.Tendsto a Filter.atTop (𝓝 0))
    (hbounded : ∃ M : ℝ, 0 < M ∧ ∀ N : ℕ, ‖Finset.sum (Finset.range N) (fun n => b (n + 1))‖ < M) :
    Summable (fun n : ℕ => (a (n + 1) : ℂ) * b (n + 1)) := by
  sorry