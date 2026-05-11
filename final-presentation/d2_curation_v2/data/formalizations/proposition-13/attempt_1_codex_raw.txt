import Mathlib

theorem outerMeasure_zero_measurable_caratheodory {α : Type*} (μ : OuterMeasure α) {s : Set α}
    (hs : μ s = 0) : MeasurableSet[μ.caratheodory] s := by
  sorry