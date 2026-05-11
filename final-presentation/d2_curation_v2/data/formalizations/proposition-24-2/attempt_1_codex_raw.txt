import Mathlib

theorem nonneg_nondecreasing_integrable_div_imp_tendsto_zero
    (f : ℝ → ℝ)
    (h_nonneg : ∀ t ∈ Set.Icc (0 : ℝ) 1, 0 ≤ f t)
    (h_mono : MonotoneOn f (Set.Icc (0 : ℝ) 1))
    (h_int : IntegrableOn (fun t : ℝ => f t / t) (Set.Ioc (0 : ℝ) 1)) :
    Filter.Tendsto f (nhdsWithin (0 : ℝ) (Set.Ioi 0)) (nhds 0) := by
  sorry