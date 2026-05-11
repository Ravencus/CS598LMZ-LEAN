import Mathlib

theorem xlog_summable_of_n_mul_summable
    {x : ℕ → ℝ}
    (hx : ∀ n : ℕ, 0 < x n ∧ x n < 1)
    (hsum : Summable (fun n : ℕ => ((n + 1 : ℕ) : ℝ) * x (n + 1))) :
    Summable (fun n : ℕ => x (n + 1) * Real.log (1 / x (n + 1))) := by
  sorry