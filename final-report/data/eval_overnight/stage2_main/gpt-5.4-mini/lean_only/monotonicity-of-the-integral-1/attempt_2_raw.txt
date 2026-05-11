import Mathlib

open MeasureTheory

theorem integral_ge_of_ae_ge
    {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} {f g : Ω → ℝ}
    (hf : Integrable f μ) (hg : Integrable g μ)
    (hfg : ∀ᵐ x ∂μ, g x ≤ f x) :
    ∫ x, f x ∂μ ≥ ∫ x, g x ∂μ := by
  have hnonneg : 0 ≤ ∫ x, f x ∂μ - ∫ x, g x ∂μ := by
    rw [← integral_sub hf hg]
    have hfg' : ∀ᵐ x ∂μ, 0 ≤ f x - g x := by
      filter_upwards [hfg] with x hx
      exact sub_nonneg.mpr hx
    exact integral_nonneg_of_ae hfg'
  exact sub_nonneg.mp hnonneg