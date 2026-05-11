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
  have hmeas : Measurable (fun x => ENNReal.ofReal (f x)) :=
    ENNReal.measurable_ofReal.comp hf_meas
  have h := (MeasureTheory.lintegral_eq_zero_iff hmeas).mp h_int_zero
  filter_upwards [h] with x hx
  have : ENNReal.ofReal (f x) = 0 := hx
  have hle : f x ≤ 0 := by
    rwa [ENNReal.ofReal_eq_zero] at this
  linarith [hf_nonneg x]