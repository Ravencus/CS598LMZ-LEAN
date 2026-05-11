import Mathlib

theorem continuous_convergenceInProbability_comp
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω)
    (f : ℝ → ℝ) (hf : Continuous f)
    (X : ℕ → Ω → ℝ) (Y : Ω → ℝ) :
    (∀ ε : ℝ, 0 < ε →
      Filter.Tendsto
        (fun n => μ {ω | ε ≤ |X n ω - Y ω|})
        Filter.atTop
        (nhds 0)) →
    (∀ ε : ℝ, 0 < ε →
      Filter.Tendsto
        (fun n => μ {ω | ε ≤ |f (X n ω) - f (Y ω)|})
        Filter.atTop
        (nhds 0)) := by
  sorry