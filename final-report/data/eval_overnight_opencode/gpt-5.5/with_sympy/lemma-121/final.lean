import Mathlib

abbrev Torus : Type := { z : ℂ // ‖z‖ = (1 : ℝ) }

#check Polynomial
#check Polynomial.eval
#check Continuous

 theorem unitCircle_polynomial_uniform_approximation
    (f : Torus → ℂ) (hf : Continuous f) :
    ∀ ε : ℝ, ε > 0 → ∃ P : Polynomial ℂ, ∀ z : Torus, ‖f z - P.eval z.1‖ < ε := by
  intro ε hε
  exact by
    aesop