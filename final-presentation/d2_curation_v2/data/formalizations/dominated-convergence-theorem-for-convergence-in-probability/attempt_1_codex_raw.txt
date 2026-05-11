import Mathlib

open MeasureTheory
open scoped ENNReal

theorem tendsto_expectation_of_tendstoInProbability_dominated
    {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} [IsProbabilityMeasure μ]
    (X : Ω → ℝ) (Xn : ℕ → Ω → ℝ) (Y : Ω → ℝ)
    (hprob :
      ∀ ε : ℝ, 0 < ε →
        Filter.Tendsto
          (fun n : ℕ => μ {ω | ε ≤ |Xn n ω - X ω|})
          Filter.atTop
          (nhds 0))
    (hdom : ∀ n ω, |Xn n ω| ≤ Y ω)
    (hY : Integrable Y μ) :
    Filter.Tendsto
      (fun n : ℕ => ∫ ω, Xn n ω ∂μ)
      Filter.atTop
      (nhds (∫ ω, X ω ∂μ)) := by
  sorry