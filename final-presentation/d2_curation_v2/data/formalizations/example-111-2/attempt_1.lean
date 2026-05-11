import Mathlib

theorem exists_rational_enumeration_of_unitInterval :
    ∃ x : ℕ → ℚ,
      Set.range x = Set.Ioo (0 : ℚ) 1 ∧
      Filter.limsup (fun n => (x n : ℝ)) Filter.atTop = 1 ∧
      Filter.liminf (fun n => (x n : ℝ)) Filter.atTop = 0 ∧
      Filter.Tendsto (fun n => ((x (n + 1) : ℝ) - (x n : ℝ))) Filter.atTop (nhds 0) ∧
      Set.Ioo (0 : ℝ) 1 ⊆ closure (Set.range fun n => (x n : ℝ)) := by
  sorry