import Mathlib

def IsBestApproximation (α : ℝ) (q : ℕ) : Prop :=
  0 < q ∧
    ∃ p : ℤ,
      ∀ q' : ℕ,
        0 < q' →
          q' ≤ q →
            ∀ p' : ℤ,
              |α - (p : ℝ) / (q : ℝ)| ≤ |α - (p' : ℝ) / (q' : ℝ)|

constant IsDenominatorOfSomeConvergent : ℝ → ℕ → Prop

theorem irrational_bestApproximation_iff_denominator_of_convergent
    {α : ℝ} (hα : Irrational α) {q : ℕ} (hq : 0 < q) :
    IsBestApproximation α q ↔ IsDenominatorOfSomeConvergent α q := by
  sorry