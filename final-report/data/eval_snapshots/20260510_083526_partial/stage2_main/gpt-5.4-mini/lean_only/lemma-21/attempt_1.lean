import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have h := Complex.norm_exp_mul_I_sub_one_le (2 * Real.pi * x)
  have hpi : 0 ≤ (2 * Real.pi : ℝ) := by positivity
  have habs : |2 * Real.pi * x| = 2 * Real.pi * |x| := by
    rw [abs_mul, abs_of_nonneg hpi]
  simpa [habs] using h