import Mathlib

theorem fibonacci_series_evaluation :
    HasSum (fun n : ℕ => 1 / ((Nat.fib (n + 1) : ℝ) * (Nat.fib (n + 3) : ℝ))) 1 := by
  sorry