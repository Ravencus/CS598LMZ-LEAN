import Mathlib

theorem limit_of_average_rpow_sequence :
    Filter.Tendsto
      (fun n : ℕ =>
        Finset.sum (Finset.Icc 1 n) (fun k => Real.rpow (n : ℝ) (1 / (k : ℝ))) / (n : ℝ))
      Filter.atTop
      (nhds (1 : ℝ)) := by
  sorry