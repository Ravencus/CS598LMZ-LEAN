import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  calc
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖
        = 2 * |Real.sin (Real.pi * x)| := by
            simpa [mul_comm, mul_left_comm, mul_assoc] using
              (Complex.norm_exp_mul_I_sub_one (2 * Real.pi * x))
    _ ≤ 2 * |Real.pi * x| := by
      gcongr
      exact Real.abs_sin_le_abs (Real.pi * x)
    _ = 2 * Real.pi * |x| := by
      simp [abs_mul, abs_of_nonneg Real.pi_nonneg, mul_comm, mul_left_comm, mul_assoc]