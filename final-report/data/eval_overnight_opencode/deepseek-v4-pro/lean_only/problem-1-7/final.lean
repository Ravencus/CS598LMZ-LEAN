import Mathlib

open Real

example (x : ℝ) (hx : 0 < x) (hx2 : x < π) : 0 < Real.sin x :=
  Real.sin_pos_of_pos_of_lt_pi hx hx2