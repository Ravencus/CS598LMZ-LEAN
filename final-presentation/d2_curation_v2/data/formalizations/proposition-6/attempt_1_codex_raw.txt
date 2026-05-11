import Mathlib

def UniformlyDistributedModOne (u : ℕ → ℝ) : Prop :=
  ∀ a b : ℝ,
    0 ≤ a →
    a ≤ b →
    b ≤ 1 →
    Filter.Tendsto
      (fun N : ℕ =>
        (((Finset.range N).filter (fun n => a ≤ u n ∧ u n < b)).card : ℝ) / (N : ℝ))
      Filter.atTop
      (nhds (b - a))

def rationalBlockSequence (n : ℕ) : ℝ :=
  let k := Nat.findGreatest (fun k : ℕ => k * (k + 1) / 2 ≤ n) n
  ((n - k * (k + 1) / 2 : ℕ) : ℝ) / ((k + 1 : ℕ) : ℝ)

theorem rationalBlockSequence_uniformlyDistributedModOne :
    UniformlyDistributedModOne rationalBlockSequence := by
  sorry