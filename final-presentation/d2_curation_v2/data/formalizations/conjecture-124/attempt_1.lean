import Mathlib

noncomputable section

open scoped Topology BigOperators
open Filter

def quadraticSinePartialSum (N : ℕ) : ℝ :=
  ∑ n in Finset.range (N + 1), Real.sin ((n : ℝ) ^ (2 : ℕ))

def quadraticSineNormalized (N : ℕ) : ℝ :=
  |quadraticSinePartialSum N| / Real.sqrt ((N : ℝ) * Real.log (Real.log (N : ℝ)))

def subsequentialLimits (u : ℕ → ℝ) : Set ℝ :=
  {x : ℝ | ∃ φ : ℕ → ℕ, StrictMono φ ∧ Filter.Tendsto (fun n => u (φ n)) Filter.atTop (nhds x)}

theorem quadratic_sine_limsup_exists_positive_constant :
    ∃ C : ℝ,
      0 < C ∧ sSup (subsequentialLimits quadraticSineNormalized) = C := by
  sorry