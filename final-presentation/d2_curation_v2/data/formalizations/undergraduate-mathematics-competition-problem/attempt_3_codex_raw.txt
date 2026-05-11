import Mathlib

theorem limit_sum_n_over_nsq_ksq_add_one :
    Filter.Tendsto
      (fun n : ℕ =>
        Finset.sum (Finset.Icc 1 n) (fun k =>
          (n : ℝ) / ((n : ℝ) ^ 2 + (k : ℝ) ^ 2 + 1))
      )
      Filter.atTop
      (Filter.nhds (Real.pi / 4)) := by
  sorry