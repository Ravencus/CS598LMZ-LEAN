import Mathlib

theorem inhomogeneous_kronecker_approximation
    {α : ℝ} (hα : Irrational α) :
    ∀ β ε : ℝ, ε > 0 → ∃ q : ℕ, 0 < q ∧ ∃ p : ℤ, |(q : ℝ) * α - β - (p : ℝ)| < ε := by
  sorry