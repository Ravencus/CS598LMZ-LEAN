import Mathlib

open MeasureTheory

theorem exists_nonmeasurable_subset_of_zeroMeasureSegment :
    volume (Set.Icc (0 : ℝ) 1 ×ˢ ({0} : Set ℝ)) = 0 ∧
      ∃ V : Set ℝ,
        V ⊆ Set.Icc (0 : ℝ) 1 ∧
        ¬ MeasurableSet[volume] V ∧
        ¬ MeasurableSet (V ×ˢ ({0} : Set ℝ)) := by
  sorry