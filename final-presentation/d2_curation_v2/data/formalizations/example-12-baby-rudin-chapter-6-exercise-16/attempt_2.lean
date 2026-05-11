import Mathlib

noncomputable section

open MeasureTheory

theorem riemannZeta_eq_floorIntegral_fixed {s : ℂ} (hs : 1 < s.re) :
    riemannZeta s =
      s * ∫ x in Set.Ici (1 : ℝ), ((Int.floor x : ℂ) / Complex.cpow (x : ℂ) (s + 1)) ∂volume := by
  sorry