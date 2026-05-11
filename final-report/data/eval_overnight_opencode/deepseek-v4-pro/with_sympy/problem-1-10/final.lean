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
  have hg_meas : Measurable (fun x : Ω => ENNReal.ofReal (f x)) :=
    ENNReal.measurable_ofReal.comp hf_meas
  have hg_aemeasurable : AEMeasurable (fun x : Ω => ENNReal.ofReal (f x)) (μ.restrict E) :=
    hg_meas.aemeasurable (μ := μ.restrict E)
  have h_int : ∫⁻ x, ENNReal.ofReal (f x) ∂(μ.restrict E) = 0 := h_int_zero
  have h_ae_zero : (fun x : Ω => ENNReal.ofReal (f x)) =ᵐ[μ.restrict E] 0 :=
    ((lintegral_eq_zero_iff' hg_aemeasurable).mp h_int)
  filter_upwards [h_ae_zero] with x hx
  have hx_val : ENNReal.ofReal (f x) = (0 : ENNReal) := hx
  by_cases hpos : 0 < f x
  · exfalso
    have hpos' : 0 < ENNReal.ofReal (f x) := by
      rw [ENNReal.ofReal_pos]
      exact hpos
    rw [hx_val] at hpos'
    exact lt_irrefl 0 hpos'
  · have hnonneg : 0 ≤ f x := hf_nonneg x
    linarith