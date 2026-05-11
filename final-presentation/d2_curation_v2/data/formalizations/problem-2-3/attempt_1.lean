import Mathlib

open Filter

theorem sqrt_sum_asymptotic_expansion :
    ∃ C : ℝ,
      Tendsto
        (fun n : ℕ =>
          (∑ k in Finset.Icc 0 n, Real.sqrt (k : ℝ)) -
            ((2 : ℝ) / 3) * (n : ℝ) * Real.sqrt (n : ℝ) -
            (1 / 2 : ℝ) * Real.sqrt (n : ℝ))
        atTop (nhds C) := by
  sorry