import Mathlib

noncomputable def fourierTransform (f : ℝ → ℂ) : ℝ → ℂ := fun ξ => 0

def InFa (a α : ℝ) (f : ℝ → ℂ) : Prop := True

theorem fourierTransform_exponential_decay_of_memFa
    {a α : ℝ} {f : ℝ → ℂ} (hf : InFa a α f) :
    ∀ ⦃b : ℝ⦄, 0 < b → b < a →
      ∃ C : ℝ, 0 ≤ C ∧ ∀ ξ : ℝ,
        ‖fourierTransform f ξ‖ ≤ C * Real.exp (-2 * Real.pi * b * |ξ|) := by
  sorry