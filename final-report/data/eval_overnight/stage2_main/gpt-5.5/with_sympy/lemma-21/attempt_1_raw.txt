import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  simpa [norm_mul, Complex.norm_ofReal, Complex.norm_I, mul_assoc, mul_left_comm, mul_comm,
    abs_mul, abs_of_pos Real.pi_pos] using
    Complex.norm_exp_mul_I_sub_one_le (2 * Real.pi * x)