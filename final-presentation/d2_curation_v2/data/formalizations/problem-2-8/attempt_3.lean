import Mathlib

theorem sum_sqrt_asymptotic_expansion :
    ∃ C : ℝ,
      Filter.Tendsto
        (fun n : ℕ =>
          (Finset.sum (Finset.Icc 0 n) fun k => Real.sqrt (k : ℝ)) -
            ((2 : ℝ) / 3) * (n : ℝ) * Real.sqrt (n : ℝ) -
            (1 / 2 : ℝ) * Real.sqrt (n : ℝ))
        Filter.atTop
        (Filter.nhds C) := by
  sorry