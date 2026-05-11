import Mathlib

theorem harmonic_log_series_diverges :
    ¬ Summable (fun n : ℕ => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2))) := by
  sorry