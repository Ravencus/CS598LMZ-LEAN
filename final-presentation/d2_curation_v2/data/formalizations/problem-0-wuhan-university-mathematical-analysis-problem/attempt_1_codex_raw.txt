import Mathlib

theorem sqrt_recurrence_limit_four
    (x : ℕ → ℝ)
    (hx1 : 0 < x 1)
    (hx2 : 0 < x 2)
    (hrec : ∀ n : ℕ, x (n + 3) = Real.sqrt (x (n + 2)) + Real.sqrt (x (n + 1))) :
    Filter.Tendsto (fun n : ℕ => x (n + 1)) Filter.atTop (nhds 4) := by
  sorry