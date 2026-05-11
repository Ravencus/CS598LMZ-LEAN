import Mathlib

theorem convex_second_difference_ge_deriv_mul_second_difference
    (I : Set ℝ) (G : ℝ → ℝ) (r : ℕ → ℝ)
    (hconv : ConvexOn ℝ I G) (hdiff : Differentiable ℝ G)
    (hr : ∀ n : ℕ, r n ∈ I) :
    ∀ n : ℕ,
      G (r (n + 2)) - 2 * G (r (n + 1)) + G (r n) ≥
        deriv G (r (n + 1)) * (r (n + 2) - 2 * r (n + 1) + r n) := by
  sorry