import Mathlib

theorem pointwise_convergence_iff_pointwise_cauchy
    {X : Type*} (f_seq : ℕ → X → ℂ) (f : X → ℂ) :
    (∀ x0 : X, Filter.Tendsto (fun n : ℕ => f_seq n x0) Filter.atTop (nhds (f x0))) ↔
    (∀ x0 : X, ∀ ε : ℝ, ε > 0 → ∃ N : ℕ, ∀ n m : ℕ, n > N → m > N →
      ‖f_seq n x0 - f_seq m x0‖ < ε) := by
  sorry