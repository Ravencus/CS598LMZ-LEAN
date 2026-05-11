import Mathlib

theorem integral_zero_on_set_ae_zero
    {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [SigmaFinite μ]
    {f : Ω → ℝ} {E : Set Ω}
    (hf_nonneg : ∀ x, 0 ≤ f x)
    (hf_meas : Measurable f)
    (hE : MeasurableSet E)
    (hE_pos : 0 < μ E)
    (h_int : ∫ x in E, f x ∂μ = 0) :
    f =ᵐ[μ.restrict E] (fun _ => 0) := by
  sorry