import Mathlib

theorem uniform_convergence_iff_uniform_cauchy
    {X : Type*} (u : ℕ → X → ℂ) (f : X → ℂ)
    (hpointwise : ∀ x : X, Filter.Tendsto (fun n : ℕ => u n x) Filter.atTop (nhds (f x))) :
    (∀ ε : ℝ, ε > 0 →
      ∃ N : ℕ, ∀ n > N,
        sSup {r : ℝ | ∃ x : X, r = ‖u n x - f x‖} < ε) ↔
    (∀ ε : ℝ, ε > 0 →
      ∃ N : ℕ, ∀ n > N, ∀ m > N,
        sSup {r : ℝ | ∃ x : X, r = ‖u n x - u m x‖} < ε) := by
  sorry