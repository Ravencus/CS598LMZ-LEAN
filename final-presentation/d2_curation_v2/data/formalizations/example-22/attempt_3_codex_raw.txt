import Mathlib

open scoped BigOperators

theorem weighted_geometric_sum_tendsto
    (r a : ℝ) (x : ℕ → ℝ)
    (hr : |r| < 1)
    (hx : Filter.Tendsto x Filter.atTop (Filter.nhds a)) :
    Filter.Tendsto
      (fun n : ℕ => ∑ k in Finset.range (n + 1), r ^ (n - k) * x k)
      Filter.atTop
      (Filter.nhds (a / (1 - r))) := by
  sorry