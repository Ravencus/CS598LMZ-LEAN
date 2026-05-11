import Mathlib

theorem parameter_dependent_sum_limit :
    Filter.Tendsto
      (fun n : ℕ =>
        ∑ k in Finset.Icc 1 n,
          (1 : ℝ) /
            ((n : ℝ) +
              (((2 : ℝ) * (k : ℝ) * ((k : ℝ) - 1)) / (((2 : ℝ) * (k : ℝ)) - 1))))
      Filter.atTop
      (nhds (Real.log 2)) := by
  sorry