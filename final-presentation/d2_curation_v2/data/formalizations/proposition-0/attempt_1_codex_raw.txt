import Mathlib

open Filter MeasureTheory

theorem almostSureConvergence_of_tendsto_expectation_and_summable_variances
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (X : ℕ → Ω → ℝ) (C : ℝ)
    (h_meas : ∀ n, Measurable (X n))
    (h_expectation : Tendsto (fun n => ∫ x, X n x ∂μ) atTop (nhds C))
    (h_variance : Summable (fun n => ∫ x, (X n x - ∫ y, X n y ∂μ) ^ 2 ∂μ)) :
    ∀ᵐ x ∂μ, Tendsto (fun n => X n x) atTop (nhds C) := by
  sorry