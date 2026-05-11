import Mathlib

theorem hermite_floor_sum (x : ℝ) (n : ℕ) :
    ∑ k in Finset.range n, Int.floor (x + (k : ℝ) / (n : ℝ)) = Int.floor ((n : ℝ) * x) := by
  sorry