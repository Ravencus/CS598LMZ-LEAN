import Mathlib

theorem sequence_limit_quadratic
    (x : ℕ → ℝ)
    (h1 : x 1 = 1)
    (hrec : ∀ n : ℕ, 1 ≤ n → x (n + 1) = x n + 3 * Real.sqrt (x n) + (n : ℝ) / Real.sqrt (x n)) :
    Filter.Tendsto (fun n : ℕ => x n / (n : ℝ) ^ 2) Filter.atTop (nhds (9 / 4 : ℝ)) := by
  sorry