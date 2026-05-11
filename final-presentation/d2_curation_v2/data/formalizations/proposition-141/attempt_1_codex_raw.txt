import Mathlib

open Set MeasureTheory

def Bad : Set ℝ :=
  { x : ℝ |
      ∃ c : ℝ,
        0 < c ∧
          ∀ p : ℤ, ∀ q : ℕ, q ≠ 0 →
            c / (q : ℝ) ^ (2 : ℕ) ≤ |x - (p : ℝ) / (q : ℝ)| }

theorem badlyApproximable_volume_eq_zero : volume Bad = 0 := by
  sorry