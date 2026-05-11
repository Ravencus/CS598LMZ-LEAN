import Mathlib

open Filter Asymptotics

theorem asymptoticExpansions_same_up_to_accuracy_O
    {S S' A A' g : ℕ → ℝ}
    (hS : (fun n => S n - A n) =O[atTop] g)
    (hS' : (fun n => S' n - A' n) =O[atTop] g)
    (hDiff : (fun n => S n - S' n) =O[atTop] g) :
    (fun n => A n - A' n) =O[atTop] g := by
  sorry