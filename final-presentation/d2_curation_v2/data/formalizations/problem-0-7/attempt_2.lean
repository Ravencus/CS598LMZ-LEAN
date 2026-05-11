import Mathlib

theorem parameter_dependent_sum_limit :
    Filter.Tendsto
      (fun n : ℕ =>
        Finset.sum (Finset.Icc 1 n) fun k =>
          (1 : ℝ) /
            ((n : ℝ) +
              (((2 : ℝ) * (k : ℝ) * ((k : ℝ) - 1)) / (((2 : ℝ) * (k : ℝ)) - 1))))
      Filter.atTop
      (𝓝 (Real.log 2)) := by
  sorry