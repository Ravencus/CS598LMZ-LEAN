import Mathlib

noncomputable section

open Filter

def newtonSqrtSeq (a x1 : ℝ) : ℕ → ℝ
  | 0 => x1
  | n + 1 => (newtonSqrtSeq a x1 n + a / newtonSqrtSeq a x1 n) / 2

def errorSeq (a x1 : ℝ) (n : ℕ) : ℝ :=
  newtonSqrtSeq a x1 n - Real.sqrt a

theorem newtonSqrtSeq_tendsto_sqrt_and_has_error_upper_bound
    {a x1 : ℝ} (ha : 0 < a) (hx1 : 0 < x1) :
    Tendsto (newtonSqrtSeq a x1) atTop (nhds (Real.sqrt a)) ∧
      ∃ B : ℕ → ℝ, (∀ n : ℕ, 0 ≤ B n) ∧ ∀ n : ℕ, |errorSeq a x1 n| ≤ B n := by
  sorry