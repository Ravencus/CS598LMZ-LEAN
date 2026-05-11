import Mathlib

theorem measurable_iInter_and_measure_limit_of_antitone
    {α : Type*} [MeasurableSpace α] (μ : Measure α) (E : ℕ → Set α)
    (h_meas : ∀ n, MeasurableSet (E n))
    (h_anti : Antitone E)
    (h_fin : ∃ n, μ (E n) < ∞) :
    MeasurableSet (⋂ n, E n) ∧
      Filter.Tendsto (fun n => μ (E n)) Filter.atTop (𝓝 (μ (⋂ n, E n))) ∧
      μ (⋂ n, E n) = ⨅ n, μ (E n) := by
  sorry