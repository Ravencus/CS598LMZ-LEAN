import Mathlib

theorem prod_an_lt_two (N : ℕ) (hN : 0 < N) :
    (∏ n ∈ Finset.Icc 1 N, (((4 : ℚ) + (3 : ℚ) ^ n) / ((2 : ℚ) + (3 : ℚ) ^ n))) < 2 := by
  sorry