import Mathlib

def EquidistributedOnClosedInterval (s : ℕ → ℝ) (a b : ℝ) : Prop :=
  ∀ ⦃f : ℝ → ℝ⦄, Continuous f →
    Filter.Tendsto
      (fun N : ℕ => (1 / (N : ℝ)) * (∑ n ∈ Finset.Icc 1 N, f (s n)))
      Filter.atTop
      (Filter.nhds ((1 / (b - a)) * (∫ x in a..b, f x)))

theorem equidistributedOnClosedInterval_average_tendsto_integral
    {s : ℕ → ℝ} {a b : ℝ}
    (hs : EquidistributedOnClosedInterval s a b) :
    ∀ ⦃f : ℝ → ℝ⦄, Continuous f →
      Filter.Tendsto
        (fun N : ℕ => (1 / (N : ℝ)) * (∑ n ∈ Finset.Icc 1 N, f (s n)))
        Filter.atTop
        (Filter.nhds ((1 / (b - a)) * (∫ x in a..b, f x))) := by
  sorry