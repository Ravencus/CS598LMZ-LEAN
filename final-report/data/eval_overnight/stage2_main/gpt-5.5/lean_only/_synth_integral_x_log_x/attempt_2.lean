import Mathlib

lemma integral_x_log_x :
    ∫ x in (0 : ℝ)..1, x * Real.log x = -1 / 4 := by
  have h :=
    (intervalIntegral.integral_id_mul_log (a := (0 : ℝ)) (b := 1))
  norm_num at h ⊢
  simpa [mul_comm] using h