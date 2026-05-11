import Mathlib

theorem positive_term_series_ratio_test_diverges
    {a : ℕ → ℝ} {r C : ℝ} {N : ℕ}
    (ha_pos : ∀ n : ℕ, 0 < a n)
    (hr : 1 < r)
    (hC : 0 ≤ C)
    (hN : 1 ≤ N)
    (hratio : ∀ n : ℕ, N ≤ n →
      |a n / a (n + 1) - (1 + 1 / (n : ℝ))| ≤ C / Real.rpow (n : ℝ) r) :
    ¬ Summable a := by
  sorry