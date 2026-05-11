import Mathlib

theorem sequence_dense_in_unit_interval :
    Set.Icc (0 : ℝ) 1 ⊆
      closure
        (Set.range
          (fun n : ℕ => ((((2 : ℝ) / 3) + (((1 : ℝ) / 3) * Real.sin n)) ^ n))) := by
  sorry