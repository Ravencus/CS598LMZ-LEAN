import Mathlib

theorem measurable_iInter_and_measure_limit_of_antitone
    {α : Type*} [MeasurableSpace α] (μ : Measure α) (E : ℕ → Set α)
    (h_meas : ∀ n, MeasurableSet (E n))
    (h_anti : Antitone E)
    (h_fin : ∃ n, μ (E n) < ∞) :
    MeasurableSet (iInter E) ∧
      Filter.Tendsto (fun n => μ (E n)) Filter.atTop (𝓝 (μ (iInter E))) ∧
      μ (iInter E) = ⨅ n, μ (E n) := by
  sorry