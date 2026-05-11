import Mathlib

theorem signedTernarySeries_eq_zero
    (r : ℕ → ℤ)
    (hr : ∀ n : ℕ, r n = 0 ∨ r n = -2 ∨ r n = 2)
    (hsum : HasSum (fun n : ℕ => (r (n + 1) : ℝ) / (3 : ℝ) ^ (n + 1)) 0) :
    ∀ n : ℕ, r (n + 1) = 0 := by
  sorry