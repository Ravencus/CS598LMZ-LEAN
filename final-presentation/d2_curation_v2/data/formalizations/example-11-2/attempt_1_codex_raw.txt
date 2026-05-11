import Mathlib

open MeasureTheory Real

theorem laplaceTransform_floor
    (s : ℝ) (hs : 0 < s) :
    ∫ x in Set.Ici (0 : ℝ), (((Int.floor x : ℤ) : ℝ) * Real.exp (-s * x)) =
      1 / (s * (Real.exp s - 1)) := by
  sorry