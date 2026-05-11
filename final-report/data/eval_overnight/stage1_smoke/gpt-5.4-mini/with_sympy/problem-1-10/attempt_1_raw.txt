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
    simpa using (MeasureTheory.lintegral_eq_zero_iff.mp h_int_zero)
  filter_upwards [hzero] with x hx
  have hto : ENNReal.toReal (ENNReal.ofReal (f x)) = ENNReal.toReal (0 : ℝ≥0∞) := by
    exact congrArg ENNReal.toReal hx
  simpa [hf_nonneg x] using hto