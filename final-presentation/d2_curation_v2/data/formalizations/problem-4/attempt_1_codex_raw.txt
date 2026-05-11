import Mathlib

open Filter Asymptotics

theorem estimate_f_sub_theta_with_littleo {f θ : ℝ → ℝ} :
    (fun x : ℝ => f x - θ x) =o[Filter.atTop] (fun x : ℝ => x) := by
  sorry