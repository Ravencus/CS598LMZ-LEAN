import Mathlib

open MeasureTheory

theorem radonNikodymIntegralFormula
    {Ω : Type*} [MeasurableSpace Ω]
    (μ ν : Measure Ω) (f g : Ω → ℝ≥0∞)
    (hf : Measurable f) (hg : Measurable g)
    (hν : ν = μ.withDensity f) :
    ∫⁻ x, g x ∂ ν = ∫⁻ x, g x * f x ∂ μ := by
  sorry