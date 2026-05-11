import Mathlib

open MeasureTheory

theorem ae_bound_successive_differences
    {α : Type*} [MeasurableSpace α] (μ : Measure α) (A : ℕ → α → ℝ) :
    ∃ M : ℝ, 0 < M ∧ ∀ n : ℕ, ∀ᵐ x ∂μ, |A (n + 1) x - A n x| ≤ (2 * M) / ((n : ℝ) + 1) := by
  sorry