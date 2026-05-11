import Mathlib

lemma integral_x_log_x :
    ∫ x in (0:ℝ)..1, x * Real.log x = -1/4 := by
  let F : ℝ → ℝ := fun x => (1 / 4 : ℝ) * ((x * x) * Real.log (x * x)) - (x * x) / 4
  have hcont : ContinuousOn F (Set.uIcc (0 : ℝ) 1) := by
    dsimp [F]
    fun_prop
  have hFderiv {x : ℝ} (hxpos : 0 < x) : HasDerivAt F (x * Real.log x) x := by
    have hx0 : x ≠ 0 := ne_of_gt hxpos
    have hxx : x * x ≠ 0 := mul_ne_zero hx0 hx0
    have h2 : HasDerivAt (fun z : ℝ => z * z) (x + x) x := by
      simpa using (hasDerivAt_id x).mul (hasDerivAt_id x)
    have hlog : HasDerivAt (fun z : ℝ => Real.log (z * z)) ((x + x) / (x * x)) x := by
      simpa using h2.log hxx
    have hA : HasDerivAt (fun z : ℝ => (z * z) * Real.log (z * z))
        ((x + x) * Real.log (x * x) + (x * x) * ((x + x) / (x * x))) x := by
      exact h2.mul hlog
    have hB : HasDerivAt (fun z : ℝ => (z * z) / 4) ((x + x) / 4) x := by
      simpa [div_eq_mul_inv] using h2.div_const 4
    have h := (hA.const_mul (1 / 4 : ℝ)).sub hB
    convert h using 1
    rw [Real.log_mul hx0 hx0]
    field_simp [hx0]
    ring
  have hderiv : ∀ x ∈ Set.uIoo (0 : ℝ) 1, DifferentiableAt ℝ F x := by
    intro x hx
    have hx' : x ∈ Set.Ioo (0 : ℝ) 1 := by simpa [Set.uIoo_of_le zero_le_one] using hx
    exact (hFderiv hx'.1).differentiableAt
  have hderiv_eq : ∀ x ∈ Set.Ioc (0 : ℝ) 1, deriv F x = x * Real.log x := by
    intro x hx
    exact (hFderiv hx.1).deriv
  have hae : (fun x : ℝ => x * Real.log x) =ᵐ[MeasureTheory.volume.restrict (Set.uIoc (0 : ℝ) 1)] deriv F := by
    exact (MeasureTheory.ae_restrict_mem measurableSet_uIoc).mono (by
      intro x hx
      have hx' : x ∈ Set.Ioc (0 : ℝ) 1 := by simpa [Set.uIoc_of_le zero_le_one] using hx
      exact (hderiv_eq x hx').symm)
  have hint : IntervalIntegrable (deriv F) MeasureTheory.volume (0 : ℝ) 1 := by
    exact (Real.continuous_mul_log.intervalIntegrable 0 1).congr_ae hae
  have hFTC := intervalIntegral.integral_deriv_eq_sub_uIoo hcont hderiv hint
  calc
    ∫ x in (0:ℝ)..1, x * Real.log x = ∫ x in (0:ℝ)..1, deriv F x := by
      apply intervalIntegral.integral_congr_ae
      apply Filter.Eventually.of_forall
      intro x hx
      have hx' : x ∈ Set.Ioc (0 : ℝ) 1 := by simpa [Set.uIoc_of_le zero_le_one] using hx
      exact (hderiv_eq x hx').symm
    _ = F 1 - F 0 := hFTC
    _ = -1/4 := by
      dsimp [F]
      norm_num