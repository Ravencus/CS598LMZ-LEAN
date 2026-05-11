import Mathlib

theorem cauchySeq_of_norm_sub_le_summable
    {α : Type*} [NormedAddCommGroup α]
    (a : ℕ → α) (b : ℕ → ℝ)
    (hbound : ∀ n : ℕ, ‖a (n + 1) - a n‖ ≤ b n)
    (hsummable : Summable b) :
    CauchySeq a := by
  sorry