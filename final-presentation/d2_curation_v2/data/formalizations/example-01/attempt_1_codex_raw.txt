import Mathlib

theorem eq_zero_iff_abs_lt_forall_pos (x : ℝ) :
    x = 0 ↔ ∀ ε > 0, |x| < ε := by
  sorry

theorem eq_zero_of_abs_lt_forall_pos (x : ℝ) (h : ∀ ε > 0, |x| < ε) : x = 0 := by
  sorry