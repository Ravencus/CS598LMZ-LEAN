import Mathlib

theorem doubleSumFloorLimit :
    Filter.Tendsto
      (fun n : ℕ =>
        ∑ i in Finset.Icc 0 n,
          ∑ j in Finset.Icc 0 (2 * n),
            ((2 : ℝ) / (n : ℝ) ^ 2) *
              ((Int.floor (((2 : ℝ) * (i : ℝ) + (j : ℝ)) / (n : ℝ))) : ℝ))
      Filter.atTop
      (nhds (6 : ℝ)) := by
  sorry