import Mathlib

theorem polynomial_uniform_approximation_on_unitInterval
    (f : C(Set.Icc (0 : ℝ) 1, ℝ)) :
    ∀ ε > 0, ∃ p : Polynomial ℝ, ∀ x : Set.Icc (0 : ℝ) 1, ‖f x - p.eval x‖ < ε := by
  sorry