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
  have _ := hE_meas
  have _ := hE_pos
  have h_ae : (fun x => ENNReal.ofReal (f x)) =ᵐ[μ.restrict E] 0 := by
    exact (MeasureTheory.lintegral_eq_zero_iff' ((hf_meas.ennreal_ofReal).aemeasurable)).mp h_int_zero
  exact h_ae.mono (fun x hx => le_antisymm (ENNReal.ofReal_eq_zero.mp hx) (hf_nonneg x))