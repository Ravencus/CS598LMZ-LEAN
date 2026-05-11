import Mathlib

open MeasureTheory

theorem outerMeasure_zero_measurable_caratheodory {α : Type*} (μ : MeasureTheory.OuterMeasure α)
    {s : Set α} (hs : μ s = 0) : MeasurableSet[μ.caratheodory] s := by
  sorry