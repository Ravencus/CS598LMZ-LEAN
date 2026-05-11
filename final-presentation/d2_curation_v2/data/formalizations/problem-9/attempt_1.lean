import Mathlib

theorem product_an_lt_two
    (N : ℕ) (hN : 0 < N) :
    (∏ n in Finset.Icc 1 N, ((4 : ℝ) + (3 : ℝ) ^ n) / ((2 : ℝ) + (3 : ℝ) ^ n)) < 2 := by
  sorry