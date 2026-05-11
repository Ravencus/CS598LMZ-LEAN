import Mathlib

theorem normalized_sequence_eventually_increasing_bounded_above
    (a : ℕ → ℝ) :
    let b : ℕ → ℝ := fun n => a n / Real.sqrt (n : ℝ)
    ∃ N : ℕ, Monotone (fun n => b (n + N)) ∧ BddAbove (Set.range fun n => b (n + N)) := by
  sorry