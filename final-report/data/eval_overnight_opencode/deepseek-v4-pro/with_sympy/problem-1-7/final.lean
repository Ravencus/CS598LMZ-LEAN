import Mathlib

example (x : ℝ) (hx : 0 < x) : Real.sin x < x := by
  exact Real.sin_lt hx