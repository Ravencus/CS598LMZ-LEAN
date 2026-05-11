import Mathlib

lemma integral_x_log_x :
    ∫ x in (0:ℝ)..1, x * Real.log x = -1 / 4 := by
  simpa [mul_comm] using
    (IntervalIntegral.integral_mul_log (a := (1 : ℝ)) (by positivity))