import Mathlib

open scoped BigOperators

theorem log_sum_lt_neg_half_log (N : ℕ) (hN : 1 ≤ N) :
    (∑ n in Finset.Icc 1 N, Real.log (1 - (1 : ℝ) / (2 * (n : ℝ)))) <
      -((1 / 2 : ℝ) * Real.log (2 * (N : ℝ))) := by
  sorry