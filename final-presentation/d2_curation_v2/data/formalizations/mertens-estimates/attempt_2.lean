import Mathlib

open scoped BigOperators

theorem mainTheorem :
    ((fun x : ℕ =>
        Finset.sum (Finset.Icc 1 x) (fun n => ArithmeticFunction.vonMangoldt n / (n : ℝ)) -
          Real.log (x : ℝ)) =O[Filter.atTop]
      (fun _ : ℕ => (1 : ℝ))) ∧
    ((fun x : ℕ =>
        Finset.sum ((Finset.Icc 1 x).filter Nat.Prime) (fun p => Real.log (p : ℝ) / (p : ℝ)) -
          Real.log (x : ℝ)) =O[Filter.atTop]
      (fun _ : ℕ => (1 : ℝ))) := by
  sorry