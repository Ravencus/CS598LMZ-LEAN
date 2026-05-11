import Mathlib

open MeasureTheory ProbabilityTheory Set

def eventsInfinitelyOften {Ω : Type*} (E : ℕ → Set Ω) : Set Ω :=
  ⋂ m : ℕ, ⋃ n ≥ m, E n

theorem borelCantelli_limsup_one
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (E : ℕ → Set Ω)
    (h_indep : ProbabilityTheory.iIndepSet E μ)
    (h_sum : (∑' n : ℕ, μ (E n)) = ∞) :
    μ (eventsInfinitelyOften E) = 1 := by
  sorry