import Mathlib
example {Ω : Type*} [MeasurableSpace Ω] {μ : MeasureTheory.Measure Ω} {g : Ω → ENNReal}
    (h : ∫⁻ x, g x ∂μ = 0) : ∀ᵐ x ∂μ, g x = 0 := by
  simpa using (MeasureTheory.lintegral_eq_zero_iff.mp h)