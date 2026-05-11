import Mathlib

theorem sequence_limit_sqrt_three
    (x : ℕ → ℝ)
    (hx0 : 0 < x 0)
    (hx1 : 0 < x 1)
    (hrec : ∀ n : ℕ, x (n + 2) = 1 / x n + 2 / x (n + 1)) :
    Filter.Tendsto x Filter.atTop (nhds (Real.sqrt 3)) := by
  sorry