import Mathlib

theorem limit_sum_sqrt :
    Filter.Tendsto
      (fun n : ℕ =>
        ∑ k in Finset.Icc 1 n,
          ((1 : ℝ) / (n : ℝ) ^ 2) *
            Real.sqrt (((n : ℝ) + k) * ((n : ℝ) + k + 1)))
      Filter.atTop
      (nhds ((3 : ℝ) / 2)) := by
  sorry