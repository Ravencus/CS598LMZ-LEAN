import Mathlib

open scoped BigOperators

theorem mainTheorem :
    ((fun x : ℕ =>
        ∑ n in Finset.Icc 1 x, ArithmeticFunction.vonMangoldt n / (n : ℝ) - Real.log (x : ℝ)) =O[Filter.atTop]
      (fun _ : ℕ => (1 : ℝ))) ∧
    ((fun x : ℕ =>
        ∑ p in (Finset.Icc 1 x).filter Nat.Prime, Real.log (p : ℝ) / (p : ℝ) - Real.log (x : ℝ)) =O[Filter.atTop]
      (fun _ : ℕ => (1 : ℝ))) := by
  sorry