import Mathlib

theorem irrational_approximation_by_multiples
    (α : ℝ) (hα : Irrational α) :
    ∀ n : ℕ, 0 < n →
      ∃ q : ℕ, 0 < q ∧ q ≤ n ∧
        ∃ p : ℤ,
          0 < |(q : ℝ) * α - (p : ℝ)| ∧
          |(q : ℝ) * α - (p : ℝ)| < 1 / (n : ℝ) := by
  sorry