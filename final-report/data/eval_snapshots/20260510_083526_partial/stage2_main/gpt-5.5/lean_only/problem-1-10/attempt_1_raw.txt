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
  have h_ofReal_zero : ∀ᵐ x ∂μ.restrict E, ENNReal.ofReal (f x) = 0 := by
    rw [MeasureTheory.lintegral_eq_zero_iff'] at h_int_zero
    exact h_int_zero
  filter_upwards [h_ofReal_zero] with x hx
  have hle : f x ≤ 0 := ENNReal.ofReal_eq_zero.mp hx
  exact le_antisymm hle (hf_nonneg x)