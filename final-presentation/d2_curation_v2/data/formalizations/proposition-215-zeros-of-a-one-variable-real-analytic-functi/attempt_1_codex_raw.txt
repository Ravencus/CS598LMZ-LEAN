import Mathlib

theorem analytic_zeros_are_isolated
    (I : Set ℝ) (f : ℝ → ℝ)
    (hI : IsOpen I)
    (hanalytic : ∀ x ∈ I, AnalyticAt ℝ f x)
    (hnonzero : ¬ ∀ x ∈ I, f x = 0) :
    ∀ x ∈ I, f x = 0 →
      ∃ ε > 0, ∀ y ∈ I, y ≠ x → |y - x| < ε → f y ≠ 0 := by
  sorry