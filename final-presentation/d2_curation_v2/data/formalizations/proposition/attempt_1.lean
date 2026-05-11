import Mathlib

theorem volume_formula_d_dimensional_ball
    (d : ℕ) (r : ℝ) :
    volume (Metric.ball (0 : EuclideanSpace ℝ (Fin d)) r) =
      ENNReal.ofReal
        ((Real.pi ^ ((d : ℝ) / 2) / Real.Gamma ((d : ℝ) / 2 + 1)) * r ^ d) := by
  sorry