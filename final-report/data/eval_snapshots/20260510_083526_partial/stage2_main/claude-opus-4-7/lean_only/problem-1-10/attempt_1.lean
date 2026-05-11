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
  have h_meas : Measurable (fun x => ENNReal.ofReal (f x)) :=
    hf_meas.ennreal_ofReal
  have h_ae : (fun x => ENNReal.ofReal (f x)) =ᵐ[μ.restrict E] 0 :=
    (MeasureTheory.lintegral_eq_zero_iff h_meas).mp h_int_zero
  filter_upwards [h_ae] with x hx
  have h0 : ENNReal.ofReal (f x) = 0 := hx
  have h_le : f x ≤ 0 := ENNReal.ofReal_eq_zero.mp h0
  linarith [hf_nonneg x]