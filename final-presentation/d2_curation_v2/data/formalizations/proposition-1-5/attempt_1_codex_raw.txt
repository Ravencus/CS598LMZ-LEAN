import Mathlib

open Asymptotics Filter

def IsAsymptoticExpansionUpTo (S A g : ℕ → ℝ) : Prop :=
  (fun n => S n - A n) =O[Filter.atTop] g

theorem same_asymptotic_expansion_of_close_sums
    {S S' A A' g : ℕ → ℝ}
    (hS : IsAsymptoticExpansionUpTo S A g)
    (hS' : IsAsymptoticExpansionUpTo S' A' g)
    (hDiff : (fun n => S n - S' n) =O[Filter.atTop] g) :
    (fun n => A n - A' n) =O[Filter.atTop] g := by
  sorry