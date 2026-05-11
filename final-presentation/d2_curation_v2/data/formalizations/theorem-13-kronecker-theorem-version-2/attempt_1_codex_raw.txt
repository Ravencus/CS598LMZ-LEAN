import Mathlib

theorem irrational_approximation_mod_one
    (α : ℝ) (hα : Irrational α) :
    ∀ β : ℝ, ∀ ε : ℝ, 0 < ε →
      ∃ q : ℕ, 0 < q ∧ ∃ z : ℤ, |(q : ℝ) * α - β - (z : ℝ)| < ε := by
  sorry