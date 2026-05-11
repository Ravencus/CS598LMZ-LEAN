import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have hsq :
      ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ^ 2 =
        4 * (Real.sin (Real.pi * x)) ^ 2 := by
    rw [Complex.exp_mul_I, Complex.sq_norm]
    simp [pow_two, mul_comm, mul_left_comm, mul_assoc]
    rw [Real.cos_two_mul, Real.sin_two_mul]
    ring_nf
    nlinarith [Real.sin_sq_add_cos_sq (Real.pi * x)]
  have hnorm :
      ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ =
        2 * |Real.sin (Real.pi * x)| := by
    have hsq' :
        ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ^ 2 =
          (2 * |Real.sin (Real.pi * x)|) ^ 2 := by
      nlinarith [hsq, sq_abs (Real.sin (Real.pi * x))]
    have hnonneg1 : 0 ≤ ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ := by
      exact norm_nonneg _
    have hnonneg2 : 0 ≤ (2 * |Real.sin (Real.pi * x)| : ℝ) := by positivity
    nlinarith
  calc
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ =
        2 * |Real.sin (Real.pi * x)| := hnorm
    _ ≤ 2 * |Real.pi * x| := by
      have hsin : |Real.sin (Real.pi * x)| ≤ |Real.pi * x| := by
        simpa using Real.abs_sin_le_abs (Real.pi * x)
      nlinarith
    _ = 2 * Real.pi * |x| := by
      rw [abs_mul]
      simp [abs_of_nonneg Real.pi_nonneg, mul_assoc]