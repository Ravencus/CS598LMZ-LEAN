import Mathlib

theorem sin_sqrt_over_n_series_converges :
    Summable (fun n : ℕ => Real.sin (Real.sqrt (((n + 1 : ℕ) : ℝ))) / (((n + 1 : ℕ) : ℝ))) := by
  sorry