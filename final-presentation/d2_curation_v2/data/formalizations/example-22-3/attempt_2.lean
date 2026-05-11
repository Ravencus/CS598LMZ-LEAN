import Mathlib

theorem telescoping_product_one_sub_inv_sq
    (n : ℕ) (hn : 1 ≤ n) :
    ∏ k ∈ Finset.Icc 2 n, (1 - 1 / ((k : ℚ) ^ 2)) =
      ((n : ℚ) + 1) / (2 * (n : ℚ)) := by
  sorry