import Mathlib

open scoped BigOperators

theorem log_squared_over_n_sum_log_reciprocals_tendsto_one :
    Filter.Tendsto
      (fun n : ℕ =>
        ((Real.log (n : ℝ)) ^ 2 / (n : ℝ)) *
          Finset.sum (Finset.Icc 2 (n - 2)) (fun k =>
            (1 : ℝ) / (Real.log (k : ℝ) * Real.log ((n - k : ℕ) : ℝ))))
      Filter.atTop
      (Filter.nhds (1 : ℝ)) := by
  sorry