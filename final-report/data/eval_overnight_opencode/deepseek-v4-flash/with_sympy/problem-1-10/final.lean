import Mathlib

4
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
  set g := fun x : Ω => ENNReal.ofReal (f x) with hg_def
  have hg_meas : Measurable g :=
    ENNReal.measurable_ofReal.comp hf_meas
  have hg_ae_zero : g =ᵐ[μ.restrict E] 0 :=
    (MeasureTheory.lintegral_eq_zero_iff (μ := μ.restrict E) hg_meas).mp h_int_zero
  filter_upwards [hg_ae_zero] with x hx
  have hfxle0 : f x ≤ 0 := (ENNReal.ofReal_eq_zero).mp hx
  exact le_antisymm hfxle0 (hf_nonneg x)