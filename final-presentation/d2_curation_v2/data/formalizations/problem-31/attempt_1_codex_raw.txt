import Mathlib

theorem sum_one_div_n_log_n_diverges :
    ¬ Summable (fun n : ℕ => if 2 ≤ n then (1 : ℝ) / ((n : ℝ) * Real.log (n : ℝ)) else 0) := by
  sorry