import Mathlib

theorem sum_sq_ge_three_products (a b c : ℝ) :
    (a + b + c) ^ 2 ≥ 3 * (a * b + b * c + a * c) := by
  nlinarith [sq_nonneg (a - b), sq_nonneg (b - c), sq_nonneg (a - c)]
