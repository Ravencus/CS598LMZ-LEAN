import Mathlib

theorem limit_of_average_rpow_sequence :
    Filter.Tendsto
      (fun n : ℕ =>
        ((∑ k in Finset.Icc 1 n, Real.rpow (n : ℝ) (1 / (k : ℝ))) / (n : ℝ)))
      Filter.atTop
      (nhds (1 : ℝ)) := by
  sorry