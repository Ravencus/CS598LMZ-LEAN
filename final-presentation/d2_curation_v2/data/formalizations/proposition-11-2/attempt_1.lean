import Mathlib

theorem outerMeasure_countable_union_isCaratheodory
    {α : Type*} (μ : MeasureTheory.OuterMeasure α) (E : ℕ → Set α)
    (hE : ∀ i : ℕ, μ.IsCaratheodory (E i)) :
    μ.IsCaratheodory (⋃ i : ℕ, E i) := by
  sorry