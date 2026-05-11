import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have h : ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ =
      2 * ‖Real.sin (Real.pi * x)‖ := by
    simpa [mul_comm, mul_left_comm, mul_assoc] using
      Complex.norm_exp_ofReal_mul_I_sub_one (2 * Real.pi * x)
  have hs : ‖Real.sin (Real.pi * x)‖ ≤ ‖Real.pi * x‖ := by
    simpa using Real.abs_sin_le (Real.pi * x)
  have hpi : ‖Real.pi * x‖ = Real.pi * |x| := by
    rw [Real.norm_eq_abs, abs_mul, abs_of_nonneg Real.pi_nonneg]
  calc
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ = 2 * ‖Real.sin (Real.pi * x)‖ := h
    _ ≤ 2 * ‖Real.pi * x‖ := by
      exact mul_le_mul_left' hs 2
    _ = 2 * Real.pi * |x| := by
      rw [hpi]
      simp [mul_assoc]