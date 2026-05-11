import Mathlib

theorem nonneg_nondecreasing_tendsto_zero_of_integrable_div
    (f : ℝ → ℝ)
    (h_nonneg : ∀ x ∈ Set.Icc (0 : ℝ) 1, 0 ≤ f x)
    (h_mono : MonotoneOn f (Set.Icc (0 : ℝ) 1))
    (h_int : IntegrableOn (fun t : ℝ => f t / t) (Set.Ioc (0 : ℝ) 1)) :
    Filter.Tendsto f (nhdsWithin 0 (Set.Ioi (0 : ℝ))) (nhds 0) := by
  sorry