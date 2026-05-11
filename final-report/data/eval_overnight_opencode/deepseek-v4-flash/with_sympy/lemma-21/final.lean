import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  set θ := 2 * Real.pi * x with hθ
  have h_nonneg : 0 ≤ 2 * Real.pi * |x| := by positivity
  have h_exp : Complex.exp ((θ : ℂ) * Complex.I) = Complex.cos θ + Complex.sin θ * Complex.I :=
    Complex.exp_add_mul_I θ
  rw [h_exp]
  have h_norm_sq_eq : ‖(Complex.cos θ + Complex.sin θ * Complex.I) - 1‖ ^ 2 = 2 - 2 * Real.cos θ := by
    calc
      ‖(Complex.cos θ + Complex.sin θ * Complex.I) - 1‖ ^ 2 = Complex.normSq ((Complex.cos θ + Complex.sin θ * Complex.I) - 1) := by
        simpa [sq] using (Complex.normSq_eq_norm_mul_self _).symm
      _ = Complex.normSq ((Complex.cos θ - 1) + Complex.sin θ * Complex.I) := by ring
      _ = (Real.cos θ - 1) ^ 2 + (Real.sin θ) ^ 2 := by
        simp [Complex.normSq_apply]
      _ = 2 - 2 * Real.cos θ := by
        nlinarith [Real.cos_sq_add_sin_sq θ]
  have h_cos_two_mul : Real.cos (2 * (Real.pi * x)) = 1 - 2 * (Real.sin (Real.pi * x)) ^ 2 := by
    nlinarith [Real.cos_two_mul (Real.pi * x), Real.sin_sq_add_cos_sq (Real.pi * x)]
  have h_abs_sq : |x| ^ 2 = x ^ 2 := by
    simpa [sq] using abs_mul_abs_self x
  have h_sin_bound : (Real.sin (Real.pi * x)) ^ 2 ≤ (Real.pi * x) ^ 2 := by
    have h_abs_sin : |Real.sin (Real.pi * x)| ≤ |Real.pi * x| := Real.abs_sin_le_abs (Real.pi * x)
    have h_sq_abs : |Real.sin (Real.pi * x)| ^ 2 ≤ |Real.pi * x| ^ 2 :=
      mul_self_le_mul_self (abs_nonneg _) h_abs_sin
    simpa [sq, abs_mul_abs_self] using h_sq_abs
  have h_ineq_sq : 2 - 2 * Real.cos θ ≤ (2 * Real.pi * |x|) ^ 2 := by
    have h_theta_eq : θ = 2 * (Real.pi * x) := by ring
    rw [h_theta_eq]
    calc
      2 - 2 * Real.cos (2 * (Real.pi * x)) = 2 - 2 * (1 - 2 * (Real.sin (Real.pi * x)) ^ 2) := by rw [h_cos_two_mul]
      _ = 4 * (Real.sin (Real.pi * x)) ^ 2 := by ring
      _ ≤ 4 * (Real.pi * x) ^ 2 := by nlinarith
      _ = 4 * (Real.pi ^ 2 * x ^ 2) := by ring
      _ = (2 * Real.pi) ^ 2 * x ^ 2 := by ring
      _ = (2 * Real.pi) ^ 2 * |x| ^ 2 := by rw [h_abs_sq]
      _ = (2 * Real.pi * |x|) ^ 2 := by ring
  have h_sq_bound : ‖(Complex.cos θ + Complex.sin θ * Complex.I) - 1‖ ^ 2 ≤ (2 * Real.pi * |x|) ^ 2 := by
    rw [h_norm_sq_eq]
    exact h_ineq_sq
  have h_nonneg_norm : 0 ≤ ‖(Complex.cos θ + Complex.sin θ * Complex.I) - 1‖ := norm_nonneg _
  nlinarith