import Mathlib

theorem sin_sqrt_and_sin_log_have_no_limits :
    (¬ ∃ l : ℝ, Filter.Tendsto (fun n : ℕ => Real.sin (Real.sqrt (n : ℝ))) Filter.atTop (Filter.nhds l)) ∧
    (¬ ∃ l : ℝ, Filter.Tendsto (fun n : ℕ => Real.sin (Real.log (n : ℝ))) Filter.atTop (Filter.nhds l)) := by
  sorry