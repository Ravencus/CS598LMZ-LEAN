import Mathlib

theorem measure_iUnion_eq_tendsto_iSup_of_monotone
    {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (E : ℕ → Set α)
    (h_meas : ∀ n, MeasurableSet (E n))
    (h_mono : Monotone E) :
    MeasurableSet (⋃ n, E n) ∧
      μ (⋃ n, E n) = ⨆ n, μ (E n) ∧
      Filter.Tendsto (fun n => μ (E n)) Filter.atTop (nhds (μ (⋃ n, E n))) := by
  sorry