import Mathlib

theorem double_sum_floor_identity
    (n : ℕ) (hn : 0 < n) :
    ∑ i in Finset.Icc (0 : ℕ) n,
      ∑ j in Finset.Icc (0 : ℕ) (2 * n),
        ((2 : ℚ) / (n : ℚ) ^ 2) *
          (Int.floor (((((2 : ℕ) * i + j : ℕ) : ℚ) / (n : ℚ))) : ℚ)
      =
        (6 : ℚ) + (8 : ℚ) / (n : ℚ) := by
  sorry