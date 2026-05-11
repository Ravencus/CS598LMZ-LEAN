import Mathlib

theorem zero_ae_of_limit_zero_on_unit_interval
    (f : ℝ → ℝ)
    (h : ∀ x0 ∈ Set.Icc (0 : ℝ) 1, Filter.Tendsto f (nhds x0) (nhds (0 : ℝ))) :
    f =ᵐ[Measure.restrict volume (Set.Icc (0 : ℝ) 1)] fun _ => (0 : ℝ) := by
  sorry