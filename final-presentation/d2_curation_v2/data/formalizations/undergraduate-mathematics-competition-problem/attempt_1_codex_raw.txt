import Mathlib

theorem limit_sum_n_over_nsq_ksq_add_one :
    Filter.Tendsto
      (fun n : ℕ =>
        ∑ k in Finset.Icc 1 n,
          (n : ℝ) / ((n : ℝ) ^ 2 + (k : ℝ) ^ 2 + 1))
      Filter.atTop
      (nhds (Real.pi / 4)) := by
  sorry