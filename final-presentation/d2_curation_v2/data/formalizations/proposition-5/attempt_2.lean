import Mathlib

open Filter

noncomputable def modTwoPi (x : ℝ) : ℝ :=
  x % (2 * Real.pi)

def UniformlyDistributedModTwoPi (u : ℕ → ℝ) : Prop :=
  ∀ a b : ℝ, 0 ≤ a → a ≤ b → b ≤ 2 * Real.pi →
    Filter.Tendsto
      (fun N : ℕ =>
        (∑ n ∈ Finset.range (N + 1),
          if modTwoPi (u n) ∈ Set.Icc a b then (1 : ℝ) else 0) / (((N + 1 : ℕ) : ℝ)))
      Filter.atTop
      (𝓝 ((b - a) / (2 * Real.pi)))

theorem squares_mod_two_pi_uniformly_distributed :
    UniformlyDistributedModTwoPi (fun n : ℕ => (n : ℝ) ^ 2) := by
  sorry