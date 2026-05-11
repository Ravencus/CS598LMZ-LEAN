import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  rw [Complex.norm_exp_mul_I_sub_one]
  have hpi : 0 ≤ (2 * Real.pi : ℝ) := by positivity
  calc
    2 * |Real.sin ((2 * Real.pi * x) / 2)| ≤ 2 * |(2 * Real.pi * x) / 2| := by
      exact mul_le_mul_left' (Real.abs_sin_le_abs ((2 * Real.pi * x) / 2)) 2
    _ = 2 * Real.pi * |x| := by
      simp [abs_div, abs_mul, abs_of_nonneg hpi, mul_comm, mul_left_comm, mul_assoc]