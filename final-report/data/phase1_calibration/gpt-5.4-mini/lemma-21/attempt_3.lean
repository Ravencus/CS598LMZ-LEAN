import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have hpi : (0 : ℝ) ≤ 2 * Real.pi := by positivity
  have h := Complex.norm_exp_mul_I_sub_one_le (2 * Real.pi * x)
  simpa [mul_comm, mul_left_comm, mul_assoc, abs_mul, abs_of_nonneg hpi] using h