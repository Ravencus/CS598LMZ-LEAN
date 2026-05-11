import Mathlib

noncomputable section

def flatSmoothExample (x : ℝ) : ℝ :=
  if 0 < x then Real.exp (-(1 / x)) else 0

def HasIsolatedZeros (f : ℝ → ℝ) : Prop :=
  ∀ x : ℝ, f x = 0 → ∃ ε : ℝ, 0 < ε ∧ ∀ y : ℝ, y ≠ x → |y - x| < ε → f y ≠ 0

theorem flatSmoothExample_properties :
    ContDiff ℝ ⊤ flatSmoothExample ∧
    (∀ n : ℕ, iteratedDeriv n flatSmoothExample 0 = 0) ∧
    flatSmoothExample 1 ≠ 0 ∧
    ¬ HasIsolatedZeros flatSmoothExample := by
  sorry