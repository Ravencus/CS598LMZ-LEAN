import Mathlib

-- Basel problem: sum of 1/n^2 = pi^2/6
-- Just the statement (sorry'd)
theorem basel_problem :
    HasSum (fun n : ℕ => (1 : ℝ) / (↑(n + 1)) ^ 2) (Real.pi ^ 2 / 6) := by
  sorry
