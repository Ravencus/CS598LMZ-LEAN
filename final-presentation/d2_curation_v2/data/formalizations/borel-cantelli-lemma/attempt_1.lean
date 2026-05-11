import Mathlib

theorem measure_limsup_zero_of_summable
    {X : Type*} [MeasurableSpace X] (μ : Measure X) (E : ℕ → Set X)
    (hE : ∀ n, MeasurableSet (E n))
    (hsum : Summable (fun n : ℕ => μ (E n))) :
    Filter.Tendsto (fun N : ℕ => μ (⋃ n : ℕ, E (n + N))) Filter.atTop (nhds 0) ∧
      μ {x : X | Set.Infinite {n : ℕ | x ∈ E n}} = 0 := by
  sorry