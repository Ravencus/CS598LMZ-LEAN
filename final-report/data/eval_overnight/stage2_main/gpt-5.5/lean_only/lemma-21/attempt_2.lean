import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have h :
      ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤
        |2 * Real.pi * x| := by
    simpa [Real.norm_eq_abs] using
      (Complex.norm_exp_mul_I_sub_exp_mul_I_le (2 * Real.pi * x) 0)
  calc
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ |2 * Real.pi * x| := h
    _ = 2 * Real.pi * |x| := by
      rw [abs_mul, abs_mul, abs_of_pos (by norm_num : (0 : ℝ) < 2), abs_of_pos Real.pi_pos]
      ring