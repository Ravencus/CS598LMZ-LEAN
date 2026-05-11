import Mathlib

open scoped BigOperators
open Asymptotics

def S (N : ℕ) : ℝ :=
  ∑ n in Finset.Icc (N + 1) (N ^ 2), 1 / ((n : ℝ) ^ 2 + 1)

theorem sum_reciprocal_sq_plus_one_bigO :
    ((fun N : ℕ => S N) =O[Filter.atTop] (fun _ : ℕ => (1 : ℝ))) ∧
      ((fun N : ℕ => S N) =O[Filter.atTop] (fun N : ℕ => 1 / Real.sqrt (N : ℝ))) := by
  sorry