import Mathlib

open scoped BigOperators

abbrev Torus := { z : ℂ // ‖z‖ = 1 }

theorem absoluteSummable_fourierCoefficients_uniformConvergence
    {f : Torus → ℂ} {fhat : ℤ → ℂ}
    (hf : Continuous f)
    (hcoeff : Summable (fun n : ℤ => ‖fhat n‖)) :
    TendstoUniformly
      (fun N : ℕ => fun z : Torus =>
        ∑ n ∈ Finset.Icc (-(N : ℤ)) (N : ℤ), fhat n * ((z : ℂ) ^ (n : ℤ)))
      f
      Filter.atTop := by
  sorry