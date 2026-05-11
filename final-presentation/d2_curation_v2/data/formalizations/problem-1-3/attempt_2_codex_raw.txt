import Mathlib

theorem doubleSumFloorLimit :
    Filter.Tendsto
      (fun n : ℕ =>
        Finset.sum (Finset.Icc 0 n) (fun i =>
          Finset.sum (Finset.Icc 0 (2 * n)) (fun j =>
            ((2 : ℝ) / (n : ℝ) ^ 2) *
              ((Int.floor (((2 : ℝ) * (i : ℝ) + (j : ℝ)) / (n : ℝ))) : ℝ))))
      Filter.atTop
      (nhds (6 : ℝ)) := by
  sorry