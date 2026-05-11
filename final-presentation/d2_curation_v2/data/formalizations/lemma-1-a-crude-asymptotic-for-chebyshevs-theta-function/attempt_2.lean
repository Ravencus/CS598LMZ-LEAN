import Mathlib

open Asymptotics
open scoped BigOperators

noncomputable def theta (x : ℝ) : ℝ :=
  ∑ p in (Finset.range (Nat.floor x + 1)).filter Nat.Prime, Real.log (p : ℝ)

theorem chebyshevTheta_asymptotic :
    (fun x : ℝ => theta x - x) =o[Filter.atTop] (fun x : ℝ => x) := by
  sorry