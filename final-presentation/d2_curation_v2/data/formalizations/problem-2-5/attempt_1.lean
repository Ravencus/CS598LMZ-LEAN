import Mathlib

theorem entire_bounded_by_power_is_polynomial
    {f : ℂ → ℂ} {M A : ℝ}
    (hentire : Differentiable ℂ f)
    (hM : 0 ≤ M)
    (hbound : ∀ z : ℂ, ‖f z‖ ≤ M * Real.rpow (1 + ‖z‖) A) :
    ∃ p : Polynomial ℂ, (∀ z : ℂ, f z = p.eval z) ∧ p.natDegree ≤ Int.toNat ⌊A⌋ := by
  sorry