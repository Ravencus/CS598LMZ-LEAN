import Mathlib

theorem averaged_difference_tendsTo_ae_zero
    {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (Y S T : ℕ → α → ℝ)
    (hT : ∀ n x, T n x = ∑ i in Finset.range (n + 1), Y i x) :
    ∀ᵐ x ∂μ, Filter.Tendsto
      (fun n : ℕ => T n x / (n : ℝ) - S n x / (n : ℝ))
      Filter.atTop
      (nhds 0) := by
  sorry