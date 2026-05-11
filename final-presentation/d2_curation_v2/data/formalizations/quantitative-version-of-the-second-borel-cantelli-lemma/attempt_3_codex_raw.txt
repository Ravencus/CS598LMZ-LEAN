import Mathlib

open scoped BigOperators
open MeasureTheory

def limsupEvent {Ω : Type*} (E : ℕ → Set Ω) : Set Ω :=
  {ω | Set.Infinite {n : ℕ | ω ∈ E (n + 1)}}

theorem probability_limsup_ge_inv_of_second_moment_bound
    {Ω : Type*} [MeasurableSpace Ω]
    (μ : Measure Ω) [IsProbabilityMeasure μ]
    (E : ℕ → Set Ω)
    (hE : ∀ n : ℕ, MeasurableSet (E n))
    (C : ENNReal)
    (hC : 0 < C)
    (hbound :
      Set.Infinite
        {N : ℕ |
          0 < N ∧
            (∑ i in Finset.Icc 1 N, ∑ j in Finset.Icc 1 N, μ (E i ∩ E j)) ≤
              C * (∑ i in Finset.Icc 1 N, μ (E i)) ^ 2})
    (hdiv : (∑' n : ℕ, μ (E (n + 1))) = ⊤) :
    (1 : ENNReal) / C ≤ μ (limsupEvent E) := by
  sorry