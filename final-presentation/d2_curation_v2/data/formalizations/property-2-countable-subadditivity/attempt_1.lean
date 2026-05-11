import Mathlib

theorem measure_iUnion_from_one_le_tsum {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (E : ℕ → Set α) :
    μ (⋃ n : ℕ, E (n + 1)) ≤ ∑' n : ℕ, μ (E (n + 1)) := by
  sorry