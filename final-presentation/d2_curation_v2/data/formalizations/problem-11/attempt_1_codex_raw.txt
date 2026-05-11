import Mathlib

theorem summable_rpow_of_summable
    {a : ℕ → ℝ}
    (ha : ∀ n, 0 < a n)
    (hs : Summable (fun n : ℕ => a (n + 1))) :
    Summable (fun n : ℕ => Real.rpow (a (n + 1)) ((n + 1 : ℝ) / (n + 2 : ℝ))) := by
  sorry