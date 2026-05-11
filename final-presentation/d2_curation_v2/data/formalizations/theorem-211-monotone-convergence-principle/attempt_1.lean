import Mathlib

theorem monotone_bounded_real_sequence_has_limit
    (u : ℕ → ℝ)
    (hmono : Monotone u ∨ Antitone u)
    (hbounded : BddAbove (Set.range u) ∧ BddBelow (Set.range u)) :
    ∃ l : ℝ, Filter.Tendsto u Filter.atTop (nhds l) := by
  sorry