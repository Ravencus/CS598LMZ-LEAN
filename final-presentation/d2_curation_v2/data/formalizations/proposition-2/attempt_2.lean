import Mathlib

def UniformlyDistributedModOne (u : ℕ → ℝ) : Prop :=
  ∀ a b : ℝ,
    0 ≤ a →
    a ≤ b →
    b ≤ 1 →
      Filter.Tendsto
        (fun N : ℕ =>
          (∑ n ∈ Finset.range N, if Real.fract (u n) ∈ Set.Icc a b then (1 : ℝ) else 0) / (N : ℝ))
        Filter.atTop
        (𝓝 (b - a))

theorem kronecker_uniformDistributed_modOne
    {γ : ℝ} (hγ_pos : 0 < γ) (hγ_irr : Irrational γ) :
    UniformlyDistributedModOne (fun n : ℕ => (n : ℝ) * γ) := by
  sorry