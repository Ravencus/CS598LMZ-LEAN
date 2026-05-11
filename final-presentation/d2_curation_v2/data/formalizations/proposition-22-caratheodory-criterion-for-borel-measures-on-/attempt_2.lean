import Mathlib

open MeasureTheory

theorem outerMeasure_of_separated_sets_additive_is_borel
    {X : Type*} [MetricSpace X] (μ : MeasureTheory.OuterMeasure X)
    (hμ : ∀ A B : Set X,
      (∃ ε > (0 : ℝ), ∀ a ∈ A, ∀ b ∈ B, ε ≤ dist a b) →
        μ (A ∪ B) = μ A + μ B) :
    borel X ≤ μ.caratheodory := by
  sorry