import Mathlib

theorem cauchyCondensation
    (a : ℕ → ℝ)
    (hmono : ∀ n : ℕ, a (n + 1) ≤ a n)
    (hnonneg : ∀ n : ℕ, 0 ≤ a n) :
    Summable (fun n : ℕ => a (n + 1)) ↔
      Summable (fun k : ℕ => (2 : ℝ) ^ k * a (2 ^ k)) := by
  sorry