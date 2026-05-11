import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have h :
      ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤
        |2 * Real.pi * x| := by
    simpa [mul_comm, Real.norm_eq_abs] using
      (Real.norm_exp_I_mul_ofReal_sub_one_le (x := 2 * Real.pi * x))
  have habs : |2 * Real.pi * x| = 2 * Real.pi * |x| := by
    rw [abs_mul, abs_mul, abs_of_pos Real.pi_pos]
    norm_num
  exact h.trans_eq habs