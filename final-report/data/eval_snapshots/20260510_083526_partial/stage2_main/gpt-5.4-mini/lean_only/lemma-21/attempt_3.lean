import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have hexp :
      Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) =
        Complex.ofReal (Real.cos (2 * Real.pi * x)) +
          Complex.ofReal (Real.sin (2 * Real.pi * x)) * Complex.I := by
    simpa [mul_comm, mul_left_comm, mul_assoc] using
      Complex.exp_ofReal_mul_I (2 * Real.pi * x)
  have hsq :
      ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ^ 2 =
        (2 * Real.sin ((2 * Real.pi * x) / 2)) ^ 2 := by
    rw [hexp, Complex.sq_abs]
    nlinarith [Real.sin_sq_add_cos_sq (2 * Real.pi * x),
      Real.one_sub_cos_eq_two_mul_sq_sin (2 * Real.pi * x)]
  have hnorm :
      ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ =
        2 * |Real.sin ((2 * Real.pi * x) / 2)| := by
    have hsq' :
        ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ^ 2 =
          (2 * |Real.sin ((2 * Real.pi * x) / 2)|) ^ 2 := by
      calc
        ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ^ 2 =
            (2 * Real.sin ((2 * Real.pi * x) / 2)) ^ 2 := hsq
        _ = (2 * |Real.sin ((2 * Real.pi * x) / 2)|) ^ 2 := by
          simp [sq_abs]
    nlinarith [hsq', norm_nonneg (Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1),
      abs_nonneg (Real.sin ((2 * Real.pi * x) / 2))]
  rw [hnorm]
  have hpi : 0 ≤ (2 * Real.pi : ℝ) := by positivity
  calc
    2 * |Real.sin ((2 * Real.pi * x) / 2)| ≤ 2 * |(2 * Real.pi * x) / 2| := by
      exact mul_le_mul_left' (Real.abs_sin_le_abs ((2 * Real.pi * x) / 2)) 2
    _ = 2 * Real.pi * |x| := by
      simp [abs_div, abs_mul, abs_of_nonneg hpi, mul_comm, mul_left_comm, mul_assoc]