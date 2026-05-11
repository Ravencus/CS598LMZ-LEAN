import Mathlib

theorem limit_n_plus_sqrt_to_nth_root_over_n :
    Filter.Tendsto
      (fun n : ℕ =>
        (∑ k in Finset.Icc 1 (n + 1), Real.rpow ((n + 1 : ℝ)) (1 / (k : ℝ))) / ((n + 1 : ℝ)))
      Filter.atTop
      (nhds (1 : ℝ)) := by
  sorry