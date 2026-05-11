import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have h :
      ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤
        |2 * Real.pi * x| := by
    simpa using Complex.norm_exp_mul_I_sub_one_le (2 * Real.pi * x)
  calc
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ |2 * Real.pi * x| := h
    _ = 2 * Real.pi * |x| := by
      rw [abs_mul, abs_mul, abs_of_pos Real.two_pi_pos, abs_of_nonneg (by positivity)]
      ring