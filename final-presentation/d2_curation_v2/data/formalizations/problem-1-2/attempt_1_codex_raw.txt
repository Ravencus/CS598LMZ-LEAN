import Mathlib

theorem sin_sum_limit_main :
    Filter.Tendsto
      (fun n : ℕ =>
        ∑ k in Finset.range (n + 1), Real.sin ((k : ℝ) / (n : ℝ)^2))
      Filter.atTop
      (nhds ((1 : ℝ) / 2)) := by
  sorry