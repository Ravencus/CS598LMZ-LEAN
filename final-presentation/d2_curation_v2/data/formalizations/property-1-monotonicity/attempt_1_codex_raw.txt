import Mathlib

theorem measure_mono_of_measurable_subset
    {α : Type*} [MeasurableSpace α] (μ : Measure α) {E₁ E₂ : Set α}
    (hE₁ : MeasurableSet E₁) (hE₂ : MeasurableSet E₂) (hsubset : E₁ ⊆ E₂) :
    μ E₁ ≤ μ E₂ := by
  sorry