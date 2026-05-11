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
  have h_meas_ennreal : Measurable (fun x : Ω => ENNReal.ofReal (f x)) :=
    (ENNReal.measurable_ofReal.comp hf_meas)
  have h_int_restrict : ∫⁻ x, ENNReal.ofReal (f x) ∂(μ.restrict E) = 0 := by
    simpa using h_int_zero
  have h_ae_zero_ennreal : (fun x : Ω => ENNReal.ofReal (f x)) =ᵐ[μ.restrict E] fun _ => (0 : ENNReal) :=
    ((MeasureTheory.lintegral_eq_zero_iff h_meas_ennreal).mp h_int_restrict)
  filter_upwards [h_ae_zero_ennreal] with x hx
  have hx_nonpos : f x ≤ 0 := (ENNReal.ofReal_eq_zero.mp hx)
  have hx_eq_zero : f x = 0 :=
    le_antisymm hx_nonpos (hf_nonneg x)
  exact hx_eq_zero