import Mathlib

theorem geometric_qary_infinite_product
    (q : ℕ) (hq : 2 ≤ q) (a : ℝ) (ha : |a| < 1) :
    (∏' n : ℕ, Finset.sum (Finset.range q) (fun i => a ^ (i * q ^ n))) = 1 / (1 - a) := by
  sorry