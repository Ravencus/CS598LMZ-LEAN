import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have h := Complex.norm_exp_mul_I_sub_one_le (2 * Real.pi * x)
  calc
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ |2 * Real.pi * x| := by
      simpa using h
    _ = 2 * Real.pi * |x| := by
      rw [abs_mul, abs_mul]
      have h2 : |(2 : ℝ)| = 2 := by norm_num
      have hpi : |Real.pi| = Real.pi := abs_of_nonneg (le_of_lt Real.pi_pos)
      rw [h2, hpi]
      ring