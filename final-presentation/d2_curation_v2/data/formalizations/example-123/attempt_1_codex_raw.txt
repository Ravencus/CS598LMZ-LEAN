import Mathlib

theorem alternatingSequenceDiverges :
    let x : ℕ → ℝ := fun n => (-1 : ℝ) ^ n
    (¬ ∃ l : ℝ, Filter.Tendsto x Filter.atTop (nhds l)) ∧
      Filter.Tendsto (fun k : ℕ => x (2 * k)) Filter.atTop (nhds 1) ∧
      Filter.Tendsto (fun k : ℕ => x (2 * k + 1)) Filter.atTop (nhds (-1)) := by
  sorry