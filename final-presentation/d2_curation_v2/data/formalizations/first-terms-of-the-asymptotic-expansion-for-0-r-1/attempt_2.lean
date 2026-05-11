import Mathlib

open scoped BigOperators

axiom zeta : ℝ → ℝ

theorem pSeriesPartialSumExpansion
    {r : ℝ} (hr : 0 < r ∧ r < 1) :
    ∃ E : ℕ → ℝ, ∀ n : ℕ, 1 ≤ n →
      ((∑ k ∈ Finset.Icc 1 n, Real.rpow (k : ℝ) (-r)) =
          (1 / (1 - r)) * Real.rpow (n : ℝ) (1 - r)
            + zeta r
            + (1 / 2 : ℝ) * Real.rpow (n : ℝ) (-r)
            - (r / 12) * Real.rpow (n : ℝ) (-r - 1)
            + E n) ∧
        |E n| < (r * (r + 1) * (r + 2)) / (720 * Real.rpow (n : ℝ) (r + 3)) := by
  sorry