import Mathlib

noncomputable section

open MeasureTheory

def leftTranslation (z : ℝ) (f : ℝ → ℂ) : ℝ → ℂ :=
  fun x => f (x - z)

def convolution (f g : ℝ → ℂ) : ℝ → ℂ :=
  fun x => ∫ t : ℝ, f (x - t) * g t

theorem leftTranslation_convolution
    (z : ℝ) (f g : ℝ → ℂ) :
    leftTranslation z (convolution f g) = convolution (leftTranslation z f) g ∧
    convolution (leftTranslation z f) g = convolution f (leftTranslation z g) := by
  sorry