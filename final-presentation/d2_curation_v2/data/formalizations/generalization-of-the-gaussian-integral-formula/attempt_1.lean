import Mathlib

theorem gaussian_integral_real_euclideanSpace
    (d : ℕ) :
    (∫ x : EuclideanSpace ℝ (Fin d), Real.exp (-Real.pi * ‖x‖ ^ (2 : ℕ))) = 1 := by
  sorry