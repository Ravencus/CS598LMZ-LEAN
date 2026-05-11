import Mathlib

theorem limit_sum_sqrt :
    Filter.Tendsto
      (fun n : ℕ =>
        Finset.sum (Finset.Icc 1 n) (fun k =>
          ((1 : ℝ) / (n : ℝ) ^ 2) *
            Real.sqrt (((n : ℝ) + k) * ((n : ℝ) + k + 1))))
      Filter.atTop
      (Filter.nhds ((3 : ℝ) / 2)) := by
  sorry