import Mathlib

open Filter MeasureTheory

noncomputable section

def convolutionFun (f g : ℝ → ℂ) : ℝ → ℂ :=
  fun x => ∫ t : ℝ, f t * g (x - t)

def InC0 (h : ℝ → ℂ) : Prop :=
  Continuous h ∧
    Filter.Tendsto h Filter.atTop (𝓝 (0 : ℂ)) ∧
    Filter.Tendsto h Filter.atBot (𝓝 (0 : ℂ))

theorem lp_convolution_uniformContinuous_bounded_inC0
    {p q : ENNReal} {f g : ℝ → ℂ}
    (hf : MemLp f p volume) (hg : MemLp g q volume)
    (hp : (1 : ENNReal) ≤ p)
    (hpq : (1 : ENNReal) / p + (1 : ENNReal) / q = 1) :
    UniformContinuous (convolutionFun f g) ∧
      (∃ C : ℝ, 0 ≤ C ∧ ∀ x : ℝ, ‖convolutionFun f g x‖ ≤ C) ∧
      InC0 (convolutionFun f g) := by
  sorry