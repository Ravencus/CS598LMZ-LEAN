import Mathlib

theorem recurrence_limit_over_sqrt :
    ∀ a : ℕ → ℝ,
      a 0 = 2024 →
      (∀ n : ℕ, a (n + 1) = a n + 2 / a n) →
      Filter.Tendsto (fun n : ℕ => a n / Real.sqrt n) Filter.atTop (nhds 2) := by
  sorry