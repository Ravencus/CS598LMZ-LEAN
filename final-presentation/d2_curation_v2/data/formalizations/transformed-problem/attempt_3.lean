import Mathlib

theorem zetaTwoTail_asymptotic :
    Filter.Tendsto
      (fun N : ℕ =>
        (N : ℝ) *
          (tsum (fun n : ℕ => (1 : ℝ) / (((n + 1 : ℕ) : ℝ) ^ (2 : ℕ))) -
            ∑ n in Finset.Icc 1 N, (1 : ℝ) / ((n : ℝ) ^ (2 : ℕ)))
      Filter.atTop
      (Filter.nhds (1 : ℝ)) := by
  sorry