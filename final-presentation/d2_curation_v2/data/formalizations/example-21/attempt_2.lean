import Mathlib
open scoped BigOperators

def a (n : ℕ) : ℝ := (-1 : ℝ) ^ n

def S (n : ℕ) : ℝ := ∑ k in Finset.range (n + 1), a k

def sigma (N : ℕ) : ℝ :=
  if h : N = 0 then
    0
  else
    (∑ n in Finset.range N, S n) / (N : ℝ)

theorem alternatingSequenceCesaroSummable :
    (∀ n : ℕ, S n = if Even n then 1 else 0) ∧
    (¬ ∃ l : ℝ, Filter.Tendsto S Filter.atTop (nhds l)) ∧
    (∀ N : ℕ, N ≠ 0 → sigma N = ((Int.floor ((N : ℝ) / 2 + 1) : ℝ) / (N : ℝ))) ∧
    Filter.Tendsto sigma Filter.atTop (nhds (1 / 2 : ℝ)) := by
  sorry