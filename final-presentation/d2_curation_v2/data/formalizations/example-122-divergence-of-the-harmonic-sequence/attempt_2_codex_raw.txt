import Mathlib

open Filter

def harmonicSeq (n : ℕ) : ℝ :=
  Finset.sum (Finset.Icc 1 n) fun k => (1 : ℝ) / (k : ℝ)

theorem harmonic_sequence_diverges :
    ¬ ∃ l : ℝ, Tendsto harmonicSeq atTop (nhds l) := by
  sorry