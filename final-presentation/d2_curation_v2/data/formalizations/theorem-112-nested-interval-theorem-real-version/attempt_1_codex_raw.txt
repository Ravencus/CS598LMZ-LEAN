import Mathlib

theorem decreasing_closed_intervals_nonempty
    (a b : ℕ → ℝ)
    (h_nonempty : ∀ n : ℕ, Set.Nonempty (Set.Icc (a n) (b n)))
    (h_decreasing : ∀ n : ℕ, Set.Icc (a (n + 1)) (b (n + 1)) ⊆ Set.Icc (a n) (b n)) :
    Set.Nonempty (⋂ n : ℕ, Set.Icc (a n) (b n)) := by
  sorry