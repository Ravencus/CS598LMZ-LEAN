import Mathlib

theorem limit_zero_on_interval_implies_intervalIntegral_eq_zero
    {a b : ℝ} {f : ℝ → ℝ}
    (hlim : ∀ x₀ ∈ Set.Icc a b, Filter.Tendsto f (nhdsWithin x₀ (Set.Icc a b)) (nhds 0)) :
    IntervalIntegrable f volume a b ∧ ∫ x in a..b, f x = 0 := by
  sorry