import Mathlib

open scoped BigOperators Topology

theorem stirling_log_sum_asymptotic :
    (fun n : ℕ =>
      (∑ k in Finset.Icc 1 n, Real.log (k : ℝ)) -
        ((n : ℝ) * Real.log (n : ℝ) - (n : ℝ) +
          (1 / 2 : ℝ) * Real.log (n : ℝ) + Real.log (Real.sqrt (2 * Real.pi)))) =O[Filter.atTop]
      (fun n : ℕ => (1 : ℝ) / n) := by
  sorry