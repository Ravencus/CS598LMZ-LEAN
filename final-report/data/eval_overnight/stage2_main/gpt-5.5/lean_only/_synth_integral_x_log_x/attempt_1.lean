import Mathlib

lemma integral_x_log_x :
    ∫ x in (0:ℝ)..1, x * Real.log x = -1/4 := by
  have hderiv :
      ∀ x ∈ Set.Icc (0 : ℝ) 1,
        HasDerivAt (fun y : ℝ => (y ^ 2 / 2) * Real.log y - y ^ 2 / 4)
          (x * Real.log x) x := by
    intro x hx
    rcases eq_or_ne x 0 with rfl | hx0
    · have h :
          HasDerivAt (fun y : ℝ => (y ^ 2 / 2) * Real.log y - y ^ 2 / 4)
            0 0 := by
        simpa using
          ((hasDerivAt_const (0 : ℝ) (0 : ℝ)).sub
            ((hasDerivAt_pow 2 (0 : ℝ)).const_mul ((1 : ℝ) / 4)))
      simpa using h
    · have hlog : HasDerivAt Real.log x⁻¹ x := Real.hasDerivAt_log hx0
      have hsq : HasDerivAt (fun y : ℝ => y ^ 2 / 2) x x := by
        simpa [sq, mul_comm, mul_left_comm, mul_assoc, div_eq_mul_inv] using
          ((hasDerivAt_id x).pow 2).const_mul ((1 : ℝ) / 2)
      have hprod :
          HasDerivAt (fun y : ℝ => (y ^ 2 / 2) * Real.log y)
            ((x * Real.log x) + (x ^ 2 / 2) * x⁻¹) x :=
        hsq.mul hlog
      have hquart :
          HasDerivAt (fun y : ℝ => y ^ 2 / 4) (x / 2) x := by
        simpa [sq, mul_comm, mul_left_comm, mul_assoc, div_eq_mul_inv] using
          ((hasDerivAt_id x).pow 2).const_mul ((1 : ℝ) / 4)
      have hsub :
          HasDerivAt (fun y : ℝ => (y ^ 2 / 2) * Real.log y - y ^ 2 / 4)
            (((x * Real.log x) + (x ^ 2 / 2) * x⁻¹) - x / 2) x :=
        hprod.sub hquart
      convert hsub using 1
      field_simp [hx0]
      ring
  have hcont :
      ContinuousOn (fun y : ℝ => (y ^ 2 / 2) * Real.log y - y ^ 2 / 4)
        (Set.Icc (0 : ℝ) 1) := by
    intro x hx
    rcases eq_or_ne x 0 with rfl | hx0
    · have hlim :
          Tendsto (fun y : ℝ => (y ^ 2 / 2) * Real.log y - y ^ 2 / 4)
            (𝓝[Set.Icc (0 : ℝ) 1] 0)
            (𝓝 ((0 : ℝ) ^ 2 / 2 * Real.log 0 - (0 : ℝ) ^ 2 / 4)) := by
        simpa using
          (((continuousAt_id.pow 2).const_mul ((1 : ℝ) / 2)).mul
            Real.continuousAt_log).sub
            ((continuousAt_id.pow 2).const_mul ((1 : ℝ) / 4))
      simpa [ContinuousWithinAt] using hlim
    · exact
        (((continuousAt_id.pow 2).const_mul ((1 : ℝ) / 2)).mul
          (Real.continuousAt_log.ContinuousWithinAt)).sub
          ((continuousAt_id.pow 2).const_mul ((1 : ℝ) / 4)).ContinuousWithinAt
  have hFTC :
      ∫ x in (0 : ℝ)..1, x * Real.log x =
        ((1 : ℝ) ^ 2 / 2 * Real.log 1 - (1 : ℝ) ^ 2 / 4) -
          ((0 : ℝ) ^ 2 / 2 * Real.log 0 - (0 : ℝ) ^ 2 / 4) := by
    simpa using
      intervalIntegral.integral_eq_sub_of_hasDerivAt hderiv hcont
  rw [hFTC]
  norm_num