import Mathlib

open MeasureTheory

theorem continuityFromAboveFailsWithoutFiniteMeasure :
    let E : ℕ → Set ℝ := fun n => Set.Ici (n : ℝ)
    in
      (∀ n : ℕ, E (n + 1) ⊆ E n) ∧
      (⋂ n : ℕ, E n) = (∅ : Set ℝ) ∧
      (∀ n : ℕ, volume (E n) = ∞) := by
  sorry