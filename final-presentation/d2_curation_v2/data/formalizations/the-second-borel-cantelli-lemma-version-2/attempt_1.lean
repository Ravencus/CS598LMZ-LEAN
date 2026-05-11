import Mathlib

open MeasureTheory

def InfinitelyOften {Ω : Type*} (E : ℕ → Set Ω) : Set Ω :=
  {ω | Set.Infinite {n : ℕ | ω ∈ E n}}

def MutuallyIndependentEvents {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω)
    (E : ℕ → Set Ω) : Prop :=
  (∀ n : ℕ, MeasurableSet (E n)) ∧
    ∀ s : Finset ℕ, μ (⋂ n ∈ s, E n) = ∏ n in s, μ (E n)

theorem probability_iUnion_eq_one_implies_infinitely_often
    {Ω : Type*} [MeasurableSpace Ω] (μ : Measure Ω) [IsProbabilityMeasure μ]
    (E : ℕ → Set Ω)
    (h_indep : MutuallyIndependentEvents μ E)
    (h_lt_one : ∀ n : ℕ, μ (E n) < (1 : ℝ≥0∞))
    (h_union : μ (⋃ n : ℕ, E (n + 1)) = (1 : ℝ≥0∞)) :
    μ (InfinitelyOften E) = (1 : ℝ≥0∞) := by
  sorry