import Mathlib

theorem gaussianMeansVariancesCounterexample :
    Filter.Tendsto (fun n : ℕ => (1 : ℝ) / Real.sqrt (n + 1 : ℝ)) Filter.atTop (nhds 0) ∧
    Summable (fun n : ℕ => (1 : ℝ) / ((n + 1 : ℝ) ^ 2)) ∧
    (∀ n : ℕ, ((1 : ℝ) / Real.sqrt (n + 1 : ℝ)) ^ 2 = (1 : ℝ) / (n + 1 : ℝ)) ∧
    ¬ Summable (fun n : ℕ => (1 : ℝ) / (n + 1 : ℝ)) := by
  sorry