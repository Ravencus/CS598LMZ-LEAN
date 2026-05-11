import Mathlib

theorem limit_of_sqrt_sum :
    Filter.Tendsto
      (fun n : ℕ =>
        Finset.sum (Finset.Icc 1 n) (fun k =>
          (1 / (n : ℝ) ^ 2) *
            Real.sqrt
              (((n : ℝ) + (k : ℝ)) * (((n : ℝ) + (k : ℝ)) + 1))))
      Filter.atTop
      (nhds ((3 : ℝ) / 2)) := by
  sorry