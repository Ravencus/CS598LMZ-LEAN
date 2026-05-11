import Mathlib

open MeasureTheory

theorem integral_ge_of_ae_ge
    {Ω : Type*} [MeasurableSpace Ω] {μ : Measure Ω} {f g : Ω → ℝ}
    (hf : Integrable f μ) (hg : Integrable g μ)
    (hfg : ∀ᵐ x ∂μ, g x ≤ f x) :
    ∫ x, f x ∂μ ≥ ∫ x, g x ∂μ := by
  have hnonneg : 0 ≤ᵐ x ∂μ, f x - g x := by
    filter_upwards [hfg] with x hx
    linarith
  have hIntNonneg : 0 ≤ ∫ x, f x - g x ∂μ := by
    exact integral_nonneg hnonneg
  have hsub : ∫ x, f x - g x ∂μ = ∫ x, f x ∂μ - ∫ x, g x ∂μ := by
    simpa using (integral_sub hf hg)
  have hmain : 0 ≤ ∫ x, f x ∂μ - ∫ x, g x ∂μ := by
    rw [← hsub]
    exact hIntNonneg
  linarith