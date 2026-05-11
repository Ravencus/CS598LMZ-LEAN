import Mathlib

theorem sum_k_two_pow_k_closed_form (n : ℕ) :
    ∑ k in Finset.Icc 1 n, (k : ℤ) * (2 : ℤ) ^ k = ((n : ℤ) - 1) * (2 : ℤ) ^ (n + 1) + 2 := by
  sorry