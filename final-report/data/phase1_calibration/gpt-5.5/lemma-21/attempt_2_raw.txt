import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have hsin : ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ =
      2 * |Real.sin (Real.pi * x)| := by
    rw [Complex.exp_ofReal_mul_I]
    simp only [Complex.ofReal_mul, Complex.ofReal_ofNat, Complex.ofReal_pi]
    rw [Complex.normSq_eq_norm_sq]
    apply sq_eq_sq.mp
    · positivity
    · positivity
    · simp [Complex.normSq, sub_re, sub_im, Complex.add_re, Complex.add_im, Complex.ofReal_re,
        Complex.ofReal_im, Complex.I_re, Complex.I_im, mul_re, mul_im, sq, Real.cos_two_mul,
        Real.sin_two_mul]
      ring_nf
  rw [hsin]
  have hsin_le : |Real.sin (Real.pi * x)| ≤ |Real.pi * x| := Real.abs_sin_le_abs (Real.pi * x)
  calc
    2 * |Real.sin (Real.pi * x)| ≤ 2 * |Real.pi * x| := by
      nlinarith
    _ = 2 * Real.pi * |x| := by
      rw [abs_mul]
      rw [abs_of_nonneg (le_of_lt Real.pi_pos)]
      ring