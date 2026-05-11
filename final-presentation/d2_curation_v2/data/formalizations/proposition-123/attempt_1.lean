import Mathlib

theorem factorial_sum_identity (N : ℕ) (hN : 2 ≤ N) :
    (∑ k in Finset.range (N + 1), (1 : ℚ) / (k.factorial : ℚ)) + (1 : ℚ) / ((N * N.factorial : ℕ) : ℚ) =
      (3 : ℚ) - ∑ k in Finset.Icc 1 (N - 1), (1 : ℚ) / ((k * (k + 1) * (k + 1).factorial : ℕ) : ℚ) := by
  sorry