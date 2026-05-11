import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  simpa [Complex.ofReal_mul, Complex.ofReal_ofNat, Real.norm_eq_abs, abs_mul,
    abs_of_pos Real.pi_pos, mul_assoc, mul_left_comm, mul_comm] using
    Complex.norm_exp_mul_I_sub_one_le (2 * Real.pi * x)