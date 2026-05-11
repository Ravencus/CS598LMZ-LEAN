import Mathlib

theorem ae_zero_of_nonneg_measurable_lintegral_zero
    {Ω : Type*} [MeasurableSpace Ω] {μ : MeasureTheory.Measure Ω}
    {f : Ω → ℝ} {E : Set Ω}
    (hf_meas : Measurable f)
    (hf_nonneg : ∀ x, 0 ≤ f x)
    (hE_meas : MeasurableSet E)
    (hE_pos : 0 < μ E)
    (h_int_zero : ∫⁻ x in E, ENNReal.ofReal (f x) ∂μ = 0) :
    ∀ᵐ x ∂μ.restrict E, f x = 0 := by
  have h0 : (fun x => ENNReal.ofReal (f x)) =ᵐ[μ.restrict E] 0 := by
    exact
      (MeasureTheory.lintegral_eq_zero_iff
          (μ := μ.restrict E)
          (f := fun x => ENNReal.ofReal (f x))
          hf_meas.ennreal_ofReal).1 h_int_zero
  filter_upwards [h0] with x hx
  have hx' : f x ≤ 0 := ENNReal.ofReal_eq_zero.mp hx
  exact le_antisymm hx' (hf_nonneg x)