import Mathlib

theorem weighted_geometric_sum_tendsto
    (λ a : ℝ) (x : ℕ → ℝ)
    (hλ : |λ| < 1)
    (hx : Filter.Tendsto x Filter.atTop (Filter.nhds a)) :
    Filter.Tendsto
      (fun n : ℕ => ∑ k in Finset.range (n + 1), λ ^ (n - k) * x k)
      Filter.atTop
      (Filter.nhds (a / (1 - λ))) := by
  sorry