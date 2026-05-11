import Mathlib

open Complex
open Real

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  set φ := (Real.pi * x : ℂ) with hφ
  set z := φ * Complex.I with hz
  have h_exp_mul_neg (w : ℂ) : Complex.exp w * Complex.exp (-w) = 1 := by
    rw [← Complex.exp_add, add_neg_self, Complex.exp_zero]
  have h_exp_double_sub_one (w : ℂ) : Complex.exp (2 * w) - 1 = Complex.exp w * (Complex.exp w - Complex.exp (-w)) := by
    calc
      Complex.exp (2 * w) - 1 = Complex.exp (w + w) - 1 := by ring
      _ = (Complex.exp w * Complex.exp w) - 1 := by rw [Complex.exp_add]
      _ = (Complex.exp w * Complex.exp w) - (Complex.exp w * Complex.exp (-w)) := by
        rw [h_exp_mul_neg w]
      _ = Complex.exp w * (Complex.exp w - Complex.exp (-w)) := by ring
  have h_sin_identity (θ : ℂ) : Complex.exp (θ * Complex.I) - Complex.exp (-(θ * Complex.I)) = 2 * Complex.I * Complex.sin θ := by
    dsimp [Complex.sin]
    field_simp
    · ring
    · norm_num
  have h_main_identity : Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1 = 2 * Complex.I * Complex.exp z * Complex.sin φ := by
    calc
      Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1
          = Complex.exp (2 * z) - 1 := by
            dsimp [z, φ]
            push_cast
            ring
      _ = Complex.exp z * (Complex.exp z - Complex.exp (-z)) := by
        rw [h_exp_double_sub_one z]
      _ = Complex.exp z * (2 * Complex.I * Complex.sin φ) := by
        rw [h_sin_identity φ]
        dsimp [z]
        ring
      _ = 2 * Complex.I * Complex.exp z * Complex.sin φ := by ring
  have h_norm_exp : ‖Complex.exp z‖ = 1 := by
    calc
      ‖Complex.exp z‖ = Real.exp ((z : ℂ).re) := by rw [Complex.norm_exp]
      _ = Real.exp 0 := by
        dsimp [z, φ]
        have : ((Real.pi * x : ℂ) * Complex.I).re = (0 : ℝ) := by
          simp
        rw [this]
      _ = 1 := Real.exp_zero
  calc
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖
        = ‖2 * Complex.I * Complex.exp z * Complex.sin φ‖ := by rw [h_main_identity]
    _ = ‖(2 : ℂ)‖ * ‖Complex.I‖ * ‖Complex.exp z‖ * ‖Complex.sin φ‖ := by
      repeat' rw [norm_mul]
    _ = (2 : ℝ) * (1 : ℝ) * (1 : ℝ) * ‖Complex.sin φ‖ := by
      simp [h_norm_exp]
    _ = 2 * ‖Complex.sin φ‖ := by ring
    _ = 2 * |Real.sin (Real.pi * x)| := by
      have hsin : Complex.sin φ = (Real.sin (Real.pi * x) : ℂ) := by
        simp [φ]
      rw [hsin, Complex.norm_real]
    _ ≤ 2 * |Real.pi * x| := by
      gcongr
      apply abs_sin_le_abs
    _ = 2 * Real.pi * |x| := by
      rw [abs_mul, abs_of_pos Real.pi_pos, mul_assoc]