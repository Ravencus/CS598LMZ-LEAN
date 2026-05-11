import Mathlib

theorem factorial_exp_series_summable_iff (p : ℝ) :
    Summable
      (fun n : ℕ =>
        ((Nat.factorial (n + 1) : ℝ) * Real.exp (n + 1 : ℝ)) /
          (((n + 1 : ℝ) ^ (n + 1)) * Real.rpow (n + 1 : ℝ) p)) ↔
      (3 / 2 : ℝ) < p := by
  sorry