import Mathlib

theorem prod_one_sub_inv_two_mul_lt_inv_sqrt_two_mul
    (N : ℕ) (hN : 1 ≤ N) :
    (∏ n in Finset.Icc 1 N, (1 - (1 : ℝ) / (2 * (n : ℝ)))) <
      1 / Real.sqrt (2 * (N : ℝ)) := by
  sorry