import Mathlib

theorem baseExpansion_lex_gt_implies_gt
    (r k : ℕ) (a b : ℝ) (aDigits bDigits : ℕ → ℕ)
    (hr : 1 < r) (hk : 1 ≤ k)
    (ha : a ∈ Set.Ioo (0 : ℝ) 1) (hb : b ∈ Set.Ioo (0 : ℝ) 1)
    (ha_exp : a = ∑' n : ℕ, (aDigits n : ℝ) / (r : ℝ) ^ (n + 1))
    (hb_exp : b = ∑' n : ℕ, (bDigits n : ℝ) / (r : ℝ) ^ (n + 1))
    (ha_bound : ∀ n : ℕ, aDigits n < r)
    (hb_bound : ∀ n : ℕ, bDigits n < r)
    (hfirst : ∀ n : ℕ, n < k → aDigits n = bDigits n)
    (hnext : bDigits k < aDigits k) :
    b < a := by
  sorry