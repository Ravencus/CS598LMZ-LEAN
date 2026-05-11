import Mathlib

open Filter
open scoped BigOperators

def harmonicSeq (n : ℕ) : ℝ :=
  ∑ k in Finset.Icc 1 n, (1 : ℝ) / (k : ℝ)

theorem harmonic_sequence_diverges :
    ¬ ∃ l : ℝ, Tendsto harmonicSeq atTop (nhds l) := by
  sorry