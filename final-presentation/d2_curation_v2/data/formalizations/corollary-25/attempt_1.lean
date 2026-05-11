import Mathlib

theorem unitCircle_uniform_polynomial_approx
    (f : C({z : ℂ // ‖z‖ = 1}, ℂ)) :
    ∀ ε : ℝ, ε > 0 → ∃ p : Polynomial ℂ, ∀ z : {w : ℂ // ‖w‖ = 1}, ‖f z - p.eval z.1‖ < ε := by
  sorry