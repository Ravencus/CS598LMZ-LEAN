import Mathlib

theorem functions_gt_on_nullset_and_zero_off_compl
    {α : Type*} [MeasurableSpace α]
    (μ : MeasureTheory.Measure α) (E : Set α) (f g : α → ℝ)
    (hE : μ E = 0)
    (hfg : ∀ x ∈ E, g x < f x)
    (hzero : ∀ x ∈ Eᶜ, f x = 0 ∧ g x = 0) :
    μ E = 0 ∧ (∀ x ∈ E, g x < f x) ∧ (∀ x ∈ Eᶜ, f x = 0 ∧ g x = 0) := by
  sorry