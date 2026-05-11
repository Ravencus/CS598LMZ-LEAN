import Mathlib

theorem entire_real_part_growth_polynomial
    (f : ℂ → ℂ) (C s : ℝ)
    (hs : 0 ≤ s)
    (hentire : Differentiable ℂ f)
    (hbound : ∀ r : ℝ, 0 ≤ r → ∀ z : ℂ, ‖z‖ = r → Complex.re (f z) ≤ C * Real.rpow r s) :
    ∃ p : Polynomial ℂ, (∀ z : ℂ, Polynomial.eval z p = f z) ∧ p.natDegree ≤ Nat.ceil s := by
  sorry