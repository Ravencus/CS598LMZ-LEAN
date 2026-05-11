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
  have hzero : ∀ᵐ x ∂μ.restrict E, ENNReal.ofReal (f x) = 0 := by
    simpa using
      (ae_eq_zero_of_lintegral_eq_zero (μ := μ.restrict E)
        (f := fun x => ENNReal.ofReal (f x))
        hf_meas.ennreal h_int_zero)
  filter_upwards [hzero] with x hx
  have hxle : f x ≤ 0 := by
    simpa using hx
  exact le_antisymm hxle (hf_nonneg x)