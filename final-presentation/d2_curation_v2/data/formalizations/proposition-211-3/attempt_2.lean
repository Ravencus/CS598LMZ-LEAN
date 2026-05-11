import Mathlib

open Filter
open scoped BigOperators

def UniformlyDistributedModOne (u : ℕ → ℝ) : Prop :=
  ∀ a c : ℝ,
    0 ≤ a →
    a ≤ c →
    c ≤ 1 →
      Tendsto
        (fun N : ℕ =>
          ((Finset.sum (Finset.range N) fun n =>
              if Int.fract (u n) ∈ Set.Ico a c then (1 : ℝ) else 0) : ℝ) / (N : ℝ))
        atTop
        (nhds (c - a))

theorem logSequence_not_uniformlyDistributed_modOne (b : ℝ) :
    ¬ UniformlyDistributedModOne (fun n : ℕ => b * Real.log (n + 1)) := by
  sorry