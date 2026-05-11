import Mathlib

theorem complex_exponential_sub_one_bound (x : ℝ) :
    ‖Complex.exp (((2 * Real.pi * x : ℝ) : ℂ) * Complex.I) - 1‖ ≤ 2 * Real.pi * |x| := by
  set θ : ℝ := 2 * Real.pi * x with hθdef
  have hpi : 0 ≤ 2 * Real.pi := by positivity
  have habs : |θ| = 2 * Real.pi * |x| := by
    rw [hθdef, abs_mul, abs_of_nonneg hpi]
  suffices h : ‖Complex.exp ((θ : ℂ) * Complex.I) - 1‖ ≤ |θ| by
    rw [habs] at h; exact h
  have hexp : Complex.exp ((θ : ℂ) * Complex.I) - 1 =
      ((Real.cos θ - 1 : ℝ) : ℂ) + ((Real.sin θ : ℝ) : ℂ) * Complex.I := by
    rw [Complex.exp_mul_I]; push_cast; ring
  have hnormsq : ‖Complex.exp ((θ : ℂ) * Complex.I) - 1‖^2 = 2 - 2 * Real.cos θ := by
    rw [hexp, Complex.sq_abs, Complex.normSq_add_mul_I]
    nlinarith [Real.sin_sq_add_cos_sq θ]
  have hhalf : 1 - Real.cos θ = 2 * (Real.sin (θ/2))^2 := by
    have h2 : Real.cos θ = 1 - 2 * (Real.sin (θ/2))^2 := by
      have hcos2 := Real.cos_two_mul (θ/2)
      have hθ2 : 2 * (θ/2) = θ := by ring
      rw [hθ2] at hcos2
      have hsc := Real.sin_sq_add_cos_sq (θ/2)
      nlinarith [hsc, hcos2]
    linarith
  have hsin : |Real.sin (θ/2)| ≤ |θ/2| := Real.abs_sin_le_abs
  have hsinsq : (Real.sin (θ/2))^2 ≤ (θ/2)^2 := by
    have h1 : (Real.sin (θ/2))^2 = |Real.sin (θ/2)|^2 := (sq_abs _).symm
    have h2 : (θ/2)^2 = |θ/2|^2 := (sq_abs _).symm
    rw [h1, h2]
    exact pow_le_pow_left (abs_nonneg _) hsin 2
  have hcos : 2 - 2 * Real.cos θ ≤ θ^2 := by
    have hstep : 1 - Real.cos θ ≤ θ^2 / 2 := by
      rw [hhalf]
      nlinarith [hsinsq]
    linarith
  have hsq : ‖Complex.exp ((θ : ℂ) * Complex.I) - 1‖^2 ≤ |θ|^2 := by
    rw [hnormsq, sq_abs]; exact hcos
  exact (abs_le_of_sq_le_sq' hsq (abs_nonneg θ)).2