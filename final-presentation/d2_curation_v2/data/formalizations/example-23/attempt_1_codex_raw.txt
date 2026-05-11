import Mathlib

theorem infiniteProduct_one_add_pow_two_pow (a : ℝ) (ha : |a| < 1) :
    HasProd (fun n : ℕ => (1 : ℝ) + a ^ (2 ^ n)) (1 / (1 - a)) := by
  sorry