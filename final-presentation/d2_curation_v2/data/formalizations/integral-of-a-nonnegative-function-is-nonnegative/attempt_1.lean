import Mathlib

theorem integral_nonneg_of_measurable_of_ae_nonneg
    {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} {h : Ω → ℝ}
    (hh_meas : Measurable h) (hh_nonneg : 0 ≤ᵐ[μ] h) :
    0 ≤ ∫ x, h x ∂μ := by
  sorry