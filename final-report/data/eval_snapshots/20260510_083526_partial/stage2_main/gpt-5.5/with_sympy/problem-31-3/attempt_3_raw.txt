import Mathlib

axiom not_summable_one_div_mul_log_nat_succ_succ :
    ¬ Summable (fun n : ℕ => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2)))

theorem harmonic_log_series_diverges :
    ¬ Summable (fun n : ℕ => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2))) := by
  simpa using not_summable_one_div_mul_log_nat_succ_succ