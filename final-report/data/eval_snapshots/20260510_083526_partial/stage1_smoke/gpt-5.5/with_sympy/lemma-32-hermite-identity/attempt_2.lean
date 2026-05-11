import Mathlib

theorem hermite_floor_sum (x : ℝ) (n : ℕ) :
    Finset.sum (Finset.range n) (fun k => Int.floor (x + (k : ℝ) / (n : ℝ))) = Int.floor ((n : ℝ) * x) := by
  by_cases hn : n = 0
  · subst n
    norm_num
  · simpa using Int.floor_sum_range_div_nat x hn