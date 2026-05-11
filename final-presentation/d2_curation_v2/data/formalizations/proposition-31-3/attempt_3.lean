import Mathlib

theorem min_truncation_integral_diverges
    (f : ℝ → ℝ)
    (hf_meas : AEMeasurable f volume)
    (hf_nonneg : ∀ ⦃x : ℝ⦄, 1 ≤ x → 0 ≤ f x)
    (hf_nonincreasing : ∀ ⦃x y : ℝ⦄, 1 ≤ x → x ≤ y → f y ≤ f x)
    (hf_locInt : ∀ ⦃a : ℝ⦄, 1 ≤ a → IntervalIntegrable f volume 1 a)
    (hdiv :
      (∫⁻ x, ENNReal.ofReal (f x) ∂(volume.restrict (Set.Ioi (1 : ℝ)))) = ∞) :
    (∫⁻ x, ENNReal.ofReal (min (f x) (1 / x)) ∂(volume.restrict (Set.Ioi (1 : ℝ)))) = ∞ := by
  sorry