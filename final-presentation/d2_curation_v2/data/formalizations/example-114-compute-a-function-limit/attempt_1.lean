import Mathlib

theorem limit_sin_div_x_at_zero :
    Filter.Tendsto (fun x : ℝ => Real.sin x / x) (nhdsWithin 0 ({0}ᶜ)) (nhds 1) := by
  sorry