import Mathlib

theorem cos_pi_third : Real.cos (Real.pi / 3) = 1 / 2 := by
  rw [show Real.pi / 3 = Real.pi / 3 from rfl]
  exact Real.cos_pi_div_three
