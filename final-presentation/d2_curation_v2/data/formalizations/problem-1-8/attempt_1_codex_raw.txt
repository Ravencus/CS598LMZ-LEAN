import Mathlib

theorem zero_ae_of_limit_zero_on_unit_interval
    (f : ℝ → ℝ)
    (h : ∀ x0 ∈ Set.Icc (0 : ℝ) 1, Filter.Tendsto f (𝓝 x0) (𝓝 (0 : ℝ))) :
    f =ᵐ[volume.restrict (Set.Icc (0 : ℝ) 1)] fun _ => (0 : ℝ) := by
  sorry