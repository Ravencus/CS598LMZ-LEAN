import Mathlib

theorem outerMeasure_caratheodory_restriction_forms_measure_space
    {X : Type*} (μstar : MeasureTheory.OuterMeasure X) :
    ∃ ν : @MeasureTheory.Measure X μstar.caratheodory,
      ∀ E : Set X, @MeasurableSet X μstar.caratheodory E → ν E = μstar E := by
  sorry