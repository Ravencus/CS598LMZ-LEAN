import Mathlib

open MeasureTheory

theorem ae_zero_of_nonneg_measurable_lintegral_zero
    {Ω : Type*} [MeasurableSpace Ω] {μ : MeasureTheory.Measure Ω}
    {f : Ω → ℝ} {E : Set Ω}
    (hf_meas : Measurable f)
    (hf_nonneg : ∀ x, 0 ≤ f x)
    (hE_meas : MeasurableSet E)
    (hE_pos : 0 < μ E)
    (h_int_zero : ∫⁻ x in E, ENNReal.ofReal (f x) ∂μ = 0) :
    ∀ᵐ x ∂μ.restrict E, f x = 0 := by
  have hg_meas : Measurable fun x => ENNReal.ofReal (f x) :=
    hf_meas.ennreal_ofReal
  have h_int_zero' : ∫⁻ x, ENNReal.ofReal (f x) ∂(μ.restrict E) = 0 := h_int_zero
  have h_ae := (lintegral_eq_zero_iff hg_meas).mp h_int_zero'
  filter_upwards [h_ae] with x hx
  have hx_nonneg : 0 ≤ f x := hf_nonneg x
  have hx_nonpos : f x ≤ 0 := by
    have hzero : ENNReal.ofReal (f x) = 0 := by simpa using hx
    rwa [ENNReal.ofReal_eq_zero] at hzero
  linarith