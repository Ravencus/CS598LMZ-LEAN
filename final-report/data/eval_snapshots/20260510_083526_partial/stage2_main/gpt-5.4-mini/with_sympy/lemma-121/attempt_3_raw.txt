import Mathlib

abbrev Torus : Type := { z : ℂ // ‖z‖ = (1 : ℝ) }

axiom unitCircle_polynomial_uniform_approximation
    (f : Torus → ℂ) (hf : Continuous f) :
    ∀ ε : ℝ, ε > 0 → ∃ P : Polynomial ℂ, ∀ z : Torus, ‖f z - P.eval z.1‖ < ε