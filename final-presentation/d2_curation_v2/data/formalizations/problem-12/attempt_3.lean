import Mathlib

theorem limit_n_plus_sqrt_to_nth_root_over_n :
    Filter.Tendsto
      (fun n : ℕ =>
        Finset.sum (Finset.Icc 1 (n + 1))
          (fun k => Real.rpow ((n + 1 : ℝ)) (1 / (k : ℝ))) / ((n + 1 : ℝ)))
      Filter.atTop
      (Filter.nhds (1 : ℝ)) := by
  sorry