import Mathlib

def UniformlyDistributedModOne (u : ℕ → ℝ) : Prop :=
  ∀ x y : ℝ,
    0 ≤ x →
    x < y →
    y ≤ 1 →
      Filter.Tendsto
        (fun N : ℕ =>
          (((Finset.range N).filter fun n => x ≤ Int.fract (u n) ∧ Int.fract (u n) < y).card : ℝ) / N)
        Filter.atTop
        (nhds (y - x))

theorem power_sequence_uniformlyDistributedModOne
    {a b : ℝ} (ha : a ≠ 0) (hb0 : 0 < b) (hb1 : b < 1) :
    UniformlyDistributedModOne (fun n : ℕ => a * Real.rpow (n : ℝ) b) := by
  sorry