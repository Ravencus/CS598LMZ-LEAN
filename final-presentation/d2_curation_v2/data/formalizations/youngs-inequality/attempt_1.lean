import Mathlib

open scoped ENNReal

variable {α : Type*}

def lpNorm (p : ℝ≥0∞) (f : α → ℝ) : ℝ := 0

def convolution (f g : α → ℝ) : α → ℝ := fun _ => 0

theorem young_convolution_inequality
    (p q r : ℝ≥0∞) (f g : α → ℝ)
    (hp₁ : (1 : ℝ≥0∞) ≤ p) (hp₂ : p ≤ ⊤)
    (hq₁ : (1 : ℝ≥0∞) ≤ q) (hq₂ : q ≤ ⊤)
    (hr₁ : (1 : ℝ≥0∞) ≤ r) (hr₂ : r ≤ ⊤)
    (hpqr : (1 : ℝ≥0∞) / p + (1 : ℝ≥0∞) / q = (1 : ℝ≥0∞) / r + 1) :
    lpNorm r (convolution f g) ≤ lpNorm p g * lpNorm q f := by
  sorry