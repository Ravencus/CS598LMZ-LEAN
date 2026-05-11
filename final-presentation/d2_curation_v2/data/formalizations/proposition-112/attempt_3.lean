import Mathlib

open scoped BigOperators

theorem sum_reciprocal_n_mul_pred_lt_one (N : ℕ) (hN : 2 ≤ N) :
    Finset.sum (Finset.Icc 2 N) (fun n => (1 : ℚ) / ((n : ℚ) * ((n - 1 : ℕ) : ℚ))) < 1 := by
  sorry