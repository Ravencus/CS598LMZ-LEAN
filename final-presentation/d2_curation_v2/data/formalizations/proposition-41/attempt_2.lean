import Mathlib

noncomputable def rSeq (S : ℕ → ℝ) (n : ℕ) : ℝ :=
  S n - (((n : ℝ) * Real.log (n : ℝ)) - (n : ℝ) + (1 / 2 : ℝ) * Real.log (n : ℝ) +
    Real.log (Real.sqrt (2 * Real.pi)))

theorem stirling_remainder_bounds
    (S R : ℕ → ℝ) {n : ℕ} (hn : 0 < n)
    (hrn : rSeq S n = 1 / (12 * (n : ℝ)) + R n) :
    0 < rSeq S n ∧ rSeq S n < 1 / (12 * (n : ℝ)) := by
  sorry