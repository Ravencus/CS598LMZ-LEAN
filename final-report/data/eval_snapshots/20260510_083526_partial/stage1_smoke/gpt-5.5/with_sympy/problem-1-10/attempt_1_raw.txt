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
  have h_ofReal_zero :
      ∀ᵐ x ∂μ.restrict E, ENNReal.ofReal (f x) = 0 := by
    exact (MeasureTheory.lintegral_eq_zero_iff).mp h_int_zero
  filter_upwards [h_ofReal_zero] with x hx
  exact le_antisymm (ENNReal.ofReal_eq_zero.mp hx) (hf_nonneg x)