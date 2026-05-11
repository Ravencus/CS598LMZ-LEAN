import Mathlib

open MeasureTheory

theorem measure_zero_set_where_negPart_gt
    {X : Type*} [MeasurableSpace X] (μ : MeasureTheory.Measure X) (f : X → ℝ) :
    ∀ ε : ℝ, μ {x : X | ε < max (-f x) 0} = 0 := by
  sorry