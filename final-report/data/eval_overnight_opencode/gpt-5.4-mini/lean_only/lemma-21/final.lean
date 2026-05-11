import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  have h := Complex.norm_exp_I_mul_ofReal_sub_one (2 * Real.pi * x)
  have hx : x * (Real.pi * 2) / 2 = Real.pi * x := by ring
  have h' : ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ =
      ‖2 * Real.sin (Real.pi * x)‖ := by
    simpa [mul_comm, mul_left_comm, mul_assoc, hx] using h
  rw [h']
  have hs : |Real.sin (Real.pi * x)| ≤ |Real.pi * x| := by
    simpa using (Real.abs_sin_le_abs (x := Real.pi * x))
  calc
    ‖2 * Real.sin (Real.pi * x)‖ = 2 * |Real.sin (Real.pi * x)| := by simp
    _ ≤ 2 * |Real.pi * x| := by nlinarith
    _ = 2 * Real.pi * |x| := by
      simp [abs_mul, abs_of_pos Real.pi_pos, mul_comm, mul_left_comm, mul_assoc]