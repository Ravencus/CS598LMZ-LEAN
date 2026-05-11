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
  have hf_enn_meas : Measurable fun x => ENNReal.ofReal (f x) :=
    ENNReal.continuous_ofReal.measurable.comp hf_meas
  have hf_enn_aemeas : AEMeasurable (fun x => ENNReal.ofReal (f x)) (μ.restrict E) :=
    hf_enn_meas.aemeasurable
  have h_ae : ∀ᵐ x ∂μ.restrict E, ENNReal.ofReal (f x) = 0 := by
    exact (MeasureTheory.lintegral_eq_zero_iff' hf_enn_aemeas).mp h_int_zero
  filter_upwards [h_ae] with x hx
  exact le_antisymm (ENNReal.ofReal_eq_zero.mp hx) (hf_nonneg x)