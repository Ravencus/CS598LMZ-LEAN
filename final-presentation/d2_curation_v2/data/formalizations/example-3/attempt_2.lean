import Mathlib

open MeasureTheory

noncomputable def Y3 (p : ℝ) (ω : ℝ) : ℝ :=
  if ω ∈ (Set.Icc p 1 \ ({((1 + p) / 2)} : Set ℝ)) then 0
  else if ω ∈ (Set.Ico 0 p ∪ ({((1 + p) / 2)} : Set ℝ)) then 1
  else 0

theorem y3_pushforward_unchanged
    (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1) :
    (Measure.map (Y3 p) (volume.restrict (Set.Icc 0 1))) ({0} : Set ℝ) =
        volume (Set.Icc p 1 \ ({((1 + p) / 2)} : Set ℝ)) ∧
      volume (Set.Icc p 1 \ ({((1 + p) / 2)} : Set ℝ)) = ENNReal.ofReal (1 - p) ∧
      (Measure.map (Y3 p) (volume.restrict (Set.Icc 0 1))) ({1} : Set ℝ) =
        volume (Set.Ico 0 p ∪ ({((1 + p) / 2)} : Set ℝ)) ∧
      volume (Set.Ico 0 p ∪ ({((1 + p) / 2)} : Set ℝ)) = ENNReal.ofReal p := by
  sorry