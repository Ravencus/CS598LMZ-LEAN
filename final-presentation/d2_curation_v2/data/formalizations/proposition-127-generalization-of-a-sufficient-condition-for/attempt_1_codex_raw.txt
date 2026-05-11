import Mathlib

theorem cauchy_of_dist_succ_le_summable
    {X : Type*} [MetricSpace X] (a : ℕ → X) (b : ℕ → ℝ)
    (hdist : ∀ n : ℕ, dist (a (n + 1)) (a n) ≤ b n)
    (hsummable : Summable b) :
    Cauchy (Filter.map a Filter.atTop) := by
  sorry