import Mathlib

theorem hermite_floor_sum (x : ℝ) (n : ℕ) :
    Finset.sum (Finset.range n) (fun k => Int.floor (x + (k : ℝ) / (n : ℝ))) = Int.floor ((n : ℝ) * x) := by
  simpa using Int.sum_floor_add_div_natCast_eq_floor_mul x n