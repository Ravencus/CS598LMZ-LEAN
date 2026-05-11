import Mathlib

theorem outerMeasure_caratheodory_restriction_forms_measure_space
    {X : Type*} (μstar : OuterMeasure X) :
    ∃ ν : @Measure X μstar.caratheodory,
      ∀ E : Set X, @MeasurableSet X μstar.caratheodory E → ν E = μstar E := by
  sorry