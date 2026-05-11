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
  rw [MeasureTheory.ae_restrict_iff' hE_meas]
  have h0 : ∀ᵐ x ∂μ, x ∈ E → ENNReal.ofReal (f x) = 0 := by
    exact (MeasureTheory.setLIntegral_eq_zero_iff hE_meas hf_meas.ennreal_ofReal).mp h_int_zero
  filter_upwards [h0] with x hx hxe
  exact le_antisymm (by simpa [ENNReal.ofReal_eq_zero] using hx hxe) (hf_nonneg x)