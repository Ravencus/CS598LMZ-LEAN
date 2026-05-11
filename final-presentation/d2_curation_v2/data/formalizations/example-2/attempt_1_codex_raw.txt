import Mathlib

def aSeq (n : ℕ) : ℝ :=
  if Odd n then 0 else 1 / (n : ℝ)

theorem alternating_aSeq_diverges :
    ¬ Summable (fun n : ℕ => (-1 : ℝ) ^ (n + 1) * aSeq (n + 1)) := by
  sorry