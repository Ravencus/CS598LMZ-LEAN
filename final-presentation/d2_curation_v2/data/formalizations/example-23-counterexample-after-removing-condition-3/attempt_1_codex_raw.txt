import Mathlib

def a : ℕ → ℕ → ℚ
  | 1, 1 => 1
  | n, k =>
      if k = n then n
      else if k + 1 = n then 1 - n
      else 0

def x : ℕ → ℚ
  | 0 => 0
  | k + 1 => ((-1 : ℚ) ^ (k + 1)) / (k + 1)

def rowSum (n : ℕ) : ℚ :=
  ∑ k in Finset.range (n + 1), a n k * x k

theorem doubleSequence_counterexample :
    (∀ n ≥ 2, rowSum n = 2 * ((-1 : ℚ) ^ n)) ∧
    ¬ Filter.Tendsto rowSum Filter.atTop (nhds (0 : ℚ)) ∧
    Filter.Tendsto x Filter.atTop (nhds (0 : ℚ)) := by
  sorry