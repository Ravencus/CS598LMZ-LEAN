import Mathlib

theorem local_maximum_derivative_zero
    {f : ℝ → ℝ} {x₀ : ℝ}
    (hmax : IsLocalMax f x₀)
    (hderiv : DifferentiableAt ℝ f x₀) :
    deriv f x₀ = 0 := by
  sorry