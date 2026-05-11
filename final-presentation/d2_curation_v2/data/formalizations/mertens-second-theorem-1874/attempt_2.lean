import Mathlib

open scoped BigOperators Asymptotics

def primeReciprocalSum (x : ℕ) : ℝ :=
  ∑ p in ((Finset.Icc 2 x).filter Nat.Prime), (1 : ℝ) / (p : ℝ)

theorem mertens_constant_exists :
    ∃ B : ℝ,
      (fun x : ℕ =>
        primeReciprocalSum x - (Real.log (Real.log (x : ℝ)) + B))
        =O[Filter.atTop] (fun x : ℕ => (1 : ℝ) / Real.log (x : ℝ)) := by
  sorry