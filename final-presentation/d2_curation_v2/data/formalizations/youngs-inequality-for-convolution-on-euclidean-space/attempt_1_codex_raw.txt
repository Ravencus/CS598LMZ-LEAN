import Mathlib

theorem young_convolution_inequality
    {α E : Type*}
    (convolution : (α → E) → (α → E) → (α → E))
    (Lpnorm : ℝ≥0∞ → (α → E) → ℝ≥0∞)
    {p q r : ℝ≥0∞} {f g : α → E}
    (hp : 1 ≤ p) (hq : 1 ≤ q) (hr : 1 ≤ r)
    (hprq : 1 / p + 1 / q = 1 / r + 1) :
    Lpnorm r (convolution f g) ≤ Lpnorm p g * Lpnorm q f := by
  sorry