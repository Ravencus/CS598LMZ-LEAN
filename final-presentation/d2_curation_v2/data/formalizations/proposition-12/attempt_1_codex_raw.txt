import Mathlib

theorem outerMeasure_iUnion_of_pairwise_disjoint_caratheodory
    {α : Type*} (μ : OuterMeasure α) (E : ℕ → Set α)
    (h_meas : ∀ i, MeasurableSet[μ.caratheodory] (E i))
    (h_disj : Pairwise (fun i j => Disjoint (E i) (E j))) :
    μ (⋃ i, E i) = tsum (fun i => μ (E i)) := by
  sorry