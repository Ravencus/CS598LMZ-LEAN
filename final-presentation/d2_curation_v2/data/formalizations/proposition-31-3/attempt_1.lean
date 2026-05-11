import Mathlib

theorem min_truncation_integral_diverges
    (f : ℝ → ℝ)
    (hf_meas : AEMeasurable f volume)
    (hf_nonneg : ∀ ⦃x : ℝ⦄, 1 ≤ x → 0 ≤ f x)
    (hf_nonincreasing : ∀ ⦃x y : ℝ⦄, 1 ≤ x → x ≤ y → f y ≤ f x)
    (hf_locInt : ∀ ⦃a : ℝ⦄, 1 ≤ a → IntervalIntegrable f volume 1 a)
    (hdiv :
      ∫⁻ x in Set.Ioi (1 : ℝ), ENNReal.ofReal (f x) ∂volume = ∞) :
    ∫⁻ x in Set.Ioi (1 : ℝ), ENNReal.ofReal (min (f x) (1 / x)) ∂volume = ∞ := by
  sorry