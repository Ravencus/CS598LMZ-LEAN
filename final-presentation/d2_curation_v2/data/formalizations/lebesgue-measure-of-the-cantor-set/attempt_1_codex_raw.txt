import Mathlib

def cantorSet : Set ℝ :=
  {x : ℝ |
    x ∈ Set.Icc (0 : ℝ) 1 ∧
      ∃ a : ℕ → Fin 2,
        HasSum
          (fun n : ℕ => (2 : ℝ) * (((a n : Fin 2) : ℕ) : ℝ) / ((3 : ℝ) ^ (n + 1)))
          x}

theorem cantorSet_measure_zero : volume cantorSet = 0 := by
  sorry