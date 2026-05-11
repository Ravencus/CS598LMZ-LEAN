import Mathlib

open scoped BigOperators
open Asymptotics Filter

theorem log_sum_asymptotic :
    Asymptotics.IsBigO Filter.atTop
      (fun x : ℕ =>
        (∑ n in Finset.Icc 1 x, Real.log (n : ℝ)) -
          ((x : ℝ) * Real.log (x : ℝ) - (x : ℝ)))
      (fun x : ℕ => Real.log ((x : ℝ) + 2)) := by
  sorry