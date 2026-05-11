import Mathlib

theorem sin_limsup_liminf_atTop_and_sequences :
    Filter.limsup (Filter.map Real.sin Filter.atTop) = 1 ∧
    Filter.liminf (Filter.map Real.sin Filter.atTop) = -1 ∧
    let x : ℕ → ℝ := fun n => Real.pi / 2 + 2 * Real.pi * (n : ℝ)
    let y : ℕ → ℝ := fun n => 3 * Real.pi / 2 + 2 * Real.pi * (n : ℝ)
    Filter.Tendsto (fun n => Real.sin (x n)) Filter.atTop (nhds 1) ∧
      Filter.Tendsto (fun n => Real.sin (y n)) Filter.atTop (nhds (-1)) := by
  sorry