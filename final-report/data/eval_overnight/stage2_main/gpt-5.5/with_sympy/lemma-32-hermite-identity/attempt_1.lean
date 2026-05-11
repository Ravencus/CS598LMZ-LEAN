import Mathlib

theorem hermite_floor_sum (x : ℝ) (n : ℕ) :
    Finset.sum (Finset.range n) (fun k => Int.floor (x + (k : ℝ) / (n : ℝ))) = Int.floor ((n : ℝ) * x) := by
  simpa [add_comm, add_left_comm, add_assoc, mul_comm] using
    Int.floor_sum_range_add_div_nat x n