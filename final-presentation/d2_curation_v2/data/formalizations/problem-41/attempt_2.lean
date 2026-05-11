import Mathlib

theorem triple_floor_sum_limit :
    Filter.Tendsto
      (fun n : ℕ =>
        ((((∑ i in Finset.Icc 1 n,
              ∑ j in Finset.Icc 1 n,
                ∑ k in Finset.Icc 1 n,
                  Int.floor (((i : ℝ) + (j : ℝ) + 2 * (k : ℝ)) / (n : ℝ)) : ℤ) : ℝ) /
            (n : ℝ) ^ 3))
      Filter.atTop
      (Filter.nhds (3 / 2 : ℝ)) := by
  sorry