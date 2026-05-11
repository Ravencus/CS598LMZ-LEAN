import Mathlib

theorem evaluate_series_complex (z : ℂ) (hz : ‖z‖ < 1) :
    HasSum (fun n : ℕ => z^n / ((1 - z^(n + 1)) * (1 - z^(n + 2)))) (1 / (1 - z)^2) := by
  sorry