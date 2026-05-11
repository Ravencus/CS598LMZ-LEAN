import Mathlib

theorem zetaTwoTail_asymptotic :
    Filter.Tendsto
      (fun N : ℕ =>
        (N : ℝ) *
          ((∑' n : ℕ, (1 : ℝ) / (((n + 1 : ℕ) : ℝ) ^ 2)) -
            ∑ n in Finset.Icc 1 N, (1 : ℝ) / ((n : ℝ) ^ 2)))
      Filter.atTop
      (nhds (1 : ℝ)) := by
  sorry