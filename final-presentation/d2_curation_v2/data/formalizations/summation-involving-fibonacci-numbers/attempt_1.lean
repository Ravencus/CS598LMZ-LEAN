import Mathlib

theorem fibonacci_reciprocal_sum :
    (∑' n : ℕ, (1 : ℝ) / ((Nat.fib (n + 1) : ℝ) * (Nat.fib (n + 5) : ℝ))) = (7 : ℝ) / 18 := by
  sorry