import Mathlib

theorem summable_one_div_n_log_sq :
    Summable (fun n : ℕ => 1 / ((n : ℝ) * (Real.log (n : ℝ)) ^ 2)) := by
  sorry