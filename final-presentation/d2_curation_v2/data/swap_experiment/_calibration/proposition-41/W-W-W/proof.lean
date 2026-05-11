import Mathlib

noncomputable def rSeq (S : ℕ → ℝ) (n : ℕ) : ℝ :=
  S n - (((n : ℝ) * Real.log (n : ℝ)) - (n : ℝ) + (1 / 2 : ℝ) * Real.log (n : ℝ) +
    Real.log (Real.sqrt (2 * Real.pi)))

theorem stirling_remainder_bounds
    (S R : ℕ → ℝ) {n : ℕ} (hn : 0 < n)
    (hrn : rSeq S n = 1 / (12 * (n : ℝ)) + R n) :
    0 < rSeq S n ∧ rSeq S n < 1 / (12 * (n : ℝ)) := by
  The theorem is not provable as stated.

  `hrn` only gives
  `rSeq S n = 1 / (12 * (n : ℝ)) + R n`,
  so it does not impose any sign condition on `R n`. The conclusion
  `0 < rSeq S n ∧ rSeq S n < 1 / (12 * (n : ℝ))`
  would require, at minimum, assumptions equivalent to
  `-1 / (12 * (n : ℝ)) < R n ∧ R n < 0`.

  If you want, I can formalize the corrected Lean theorem once you provide the missing bounds on `R n`.
