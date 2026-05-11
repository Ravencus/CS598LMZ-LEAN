import Mathlib

noncomputable section

open MeasureTheory

def riemannZeta (s : ℂ) : ℂ :=
  ∑' n : ℕ, if n = 0 then 0 else 1 / Complex.cpow (n : ℂ) s

theorem riemannZeta_eq_floorIntegral {s : ℂ} (hs : 1 < s.re) :
    riemannZeta s
      = s * ∫ x in Set.Ici (1 : ℝ), ((Int.floor x : ℂ) / Complex.cpow (x : ℂ) (s + 1)) ∂volume := by
  sorry