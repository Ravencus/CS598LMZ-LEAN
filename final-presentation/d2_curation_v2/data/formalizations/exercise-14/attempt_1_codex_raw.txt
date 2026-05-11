import Mathlib

theorem summable_x_log_inv_pow_of_summable_npow_mul
    (x : ℕ → ℝ) (q : ℕ)
    (hq : 0 < q)
    (hx : ∀ n : ℕ, 0 < x n ∧ x n < 1)
    (hsum : Summable (fun n : ℕ => ((n + 1 : ℝ) ^ q) * x (n + 1))) :
    Summable (fun n : ℕ => x (n + 1) * (Real.log (1 / x (n + 1))) ^ q) := by
  sorry