import Mathlib

noncomputable section

open Classical

def powTwoIndicator (n : ℕ) : ℝ :=
  if ∃ k : ℕ, 1 ≤ k ∧ n = 2 ^ k then 1 else 0

theorem powTwoIndicatorCounterexample :
    (∀ n : ℕ, 0 ≤ powTwoIndicator n) ∧
    Summable (fun n : ℕ => powTwoIndicator (n + 2) / ((n + 2 : ℕ) : ℝ)) ∧
    ¬ Summable (fun n : ℕ => powTwoIndicator (n + 2)) := by
  sorry

theorem nonnegativeSequenceWeightedSummableImpSummableFalse :
    ¬ ∀ b : ℕ → ℝ,
        (∀ n : ℕ, 0 ≤ b n) →
        Summable (fun n : ℕ => b (n + 2) / ((n + 2 : ℕ) : ℝ)) →
        Summable (fun n : ℕ => b (n + 2)) := by
  sorry