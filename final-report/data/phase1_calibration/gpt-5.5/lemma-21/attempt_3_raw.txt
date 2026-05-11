import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have hsin_le : |Real.sin (Real.pi * x)| ≤ |Real.pi * x| :=
    Real.abs_sin_le_abs
  have hnorm : ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ =
      2 * |Real.sin (Real.pi * x)| := by
    rw [Complex.exp_ofReal_mul_I]
    rw [Complex.normSq_eq_norm_sq]
    apply sq_eq_sq.mp
    · positivity
    · positivity
    · simp [Complex.normSq, Complex.ext_iff, Complex.sub_re, Complex.sub_im,
        Complex.add_re, Complex.add_im, Complex.ofReal_re, Complex.ofReal_im,
        Complex.I_re, Complex.I_im, Complex.mul_re, Complex.mul_im, sq,
        Real.cos_two_mul, Real.sin_two_mul]
      ring_nf
  rw [hnorm]
  calc
    2 * |Real.sin (Real.pi * x)| ≤ 2 * |Real.pi * x| := by
      nlinarith
    _ = 2 * Real.pi * |x| := by
      rw [abs_mul]
      rw [abs_of_nonneg (le_of_lt Real.pi_pos)]
      ring