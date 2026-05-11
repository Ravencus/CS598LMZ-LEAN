import Mathlib

theorem prime_reciprocals_not_summable :
    ¬ Summable (fun n : ℕ => if Nat.Prime n then (1 : ℝ) / n else 0) := by
  sorry