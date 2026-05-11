import Mathlib

theorem sequence_sq_recurrence_tends_to_golden_ratio
    (x : ℕ → ℝ)
    (hx0 : 0 < x 0)
    (hrec : ∀ n : ℕ, (x (n + 1)) ^ 2 = x n + 1) :
    Filter.Tendsto x Filter.atTop (nhds ((Real.sqrt 5 + 1) / 2)) := by
  sorry