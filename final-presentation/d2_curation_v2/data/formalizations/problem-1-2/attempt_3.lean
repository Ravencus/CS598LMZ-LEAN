import Mathlib

theorem sin_sum_limit_main :
    Filter.Tendsto
      (fun n : ℕ =>
        Finset.sum (Finset.range (n + 1)) (fun k => Real.sin ((k : ℝ) / (n : ℝ) ^ 2)))
      Filter.atTop
      (Filter.nhds ((1 : ℝ) / 2)) := by
  sorry