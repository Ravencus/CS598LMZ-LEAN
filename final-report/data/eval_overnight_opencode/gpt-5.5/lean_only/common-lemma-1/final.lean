import Mathlib

example : Summable (fun n : ℕ => (⊤ : ENNReal)) := by
  exact ENNReal.summable