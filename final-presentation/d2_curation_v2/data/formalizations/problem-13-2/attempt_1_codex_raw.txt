import Mathlib

theorem dense_mod_two_pi_interval :
    Set.Icc (0 : ℝ) (2 * Real.pi) ⊆
      closure (Set.range fun n : ℕ => ((n : ℝ) % (2 * Real.pi))) := by
  sorry