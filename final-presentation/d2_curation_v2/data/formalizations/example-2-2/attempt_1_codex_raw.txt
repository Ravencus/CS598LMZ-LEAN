import Mathlib

open MeasureTheory

def Y2 (p : ℝ) (ω : ℝ) : ℕ :=
  if ω ≤ p then 1 else 0

theorem bernoulli_pushforward_on_unitInterval
    (p : ℝ) (hp : p ∈ Set.Icc (0 : ℝ) 1) :
    let μ : Measure ℝ := volume.restrict (Set.Icc (0 : ℝ) 1)
    (Measure.map (Y2 p) μ) ({0} : Set ℕ) = ENNReal.ofReal (1 - p) ∧
      (Measure.map (Y2 p) μ) ({1} : Set ℕ) = ENNReal.ofReal p := by
  sorry