import Mathlib

theorem entire_eq_zero_of_norm_le_inv_im
    (f : ℂ → ℂ)
    (hf_entire : Differentiable ℂ f)
    (hbound : ∀ z : ℂ, ‖f z‖ ≤ 1 / ‖Complex.im z‖) :
    f = 0 := by
  sorry