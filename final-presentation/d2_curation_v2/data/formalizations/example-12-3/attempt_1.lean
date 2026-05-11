import Mathlib

theorem doubleFactorialSeriesConverges :
    Summable (fun n : ℕ =>
      (((Nat.centralBinom (n + 1) : ℝ) / (4 : ℝ) ^ (n + 1)) / (2 * (n + 1) + 1 : ℝ))) := by
  sorry