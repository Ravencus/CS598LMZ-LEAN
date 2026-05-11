import Mathlib

def IsContinuedFractionExpansion (α : ℝ) (a : ℕ → ℕ) : Prop := True

def BadlyApproximable (α : ℝ) : Prop :=
  ∃ c : ℝ, 0 < c ∧ ∀ p : ℤ, ∀ q : ℕ, 0 < q → c / (q : ℝ) ^ 2 ≤ |α - (p : ℝ) / (q : ℝ)|

theorem badlyApproximable_iff_bounded_continuedFractionCoefficients
    {α : ℝ} {a : ℕ → ℕ}
    (hα : Irrational α)
    (ha : IsContinuedFractionExpansion α a) :
    BadlyApproximable α ↔ ∃ C : ℝ, 0 < C ∧ ∀ n : ℕ, (a n : ℝ) ≤ C := by
  sorry