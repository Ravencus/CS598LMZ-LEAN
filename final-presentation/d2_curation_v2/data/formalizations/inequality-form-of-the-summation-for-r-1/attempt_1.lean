import Mathlib

theorem zeta_partial_sum_euler_maclaurin
    (ζ : ℝ → ℝ) (r : ℝ) (hr : 1 < r) :
    ∃ E : ℕ → ℝ,
      ∀ n : ℕ, 1 ≤ n →
        (∑ k in Finset.Icc 1 n, Real.rpow (k : ℝ) (-r)) =
          ζ r
            + (1 / (1 - r)) * Real.rpow (n : ℝ) (1 - r)
            + (1 / 2 : ℝ) * Real.rpow (n : ℝ) (-r)
            - (r / 12 : ℝ) * Real.rpow (n : ℝ) (-r - 1)
            + E n
          ∧
        |E n| < (r * (r + 1) * (r + 2)) / (720 * Real.rpow (n : ℝ) (r + 3)) := by
  sorry