import Mathlib

example : True := by
  have := intervalIntegral.integral_eq_sub_of_hasDerivAt (a := (0:ℝ)) (b := 1) (f := fun x : ℝ => x^2/2) (f' := fun x : ℝ => x)
  trivial