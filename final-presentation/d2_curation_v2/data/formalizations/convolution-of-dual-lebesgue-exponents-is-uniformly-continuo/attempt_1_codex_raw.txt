import Mathlib

open Filter MeasureTheory

def convolutionFun (f g : ℝ → ℂ) : ℝ → ℂ :=
  fun x => ∫ t : ℝ, f t * g (x - t)

def InC0 (h : ℝ → ℂ) : Prop :=
  Continuous h ∧
    Filter.Tendsto h Filter.atTop (nhds 0) ∧
    Filter.Tendsto h Filter.atBot (nhds 0)

theorem lp_convolution_uniformContinuous_bounded_inC0
    {p q : ℝ≥0∞} {f g : ℝ → ℂ}
    (hf : MemLp f p volume) (hg : MemLp g q volume)
    (hp : (1 : ℝ≥0∞) ≤ p)
    (hpq : (1 : ℝ≥0∞) / p + (1 : ℝ≥0∞) / q = 1) :
    UniformContinuous (convolutionFun f g) ∧
      (∃ C : ℝ, 0 ≤ C ∧ ∀ x : ℝ, ‖convolutionFun f g x‖ ≤ C) ∧
      InC0 (convolutionFun f g) := by
  sorry