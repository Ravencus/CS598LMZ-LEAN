import Mathlib

open scoped BigOperators Topology Interval
open Filter MeasureTheory

noncomputable section

def SubpolynomialGrowth (f : ℕ → ℂ) : Prop :=
  ∀ ε : ℝ, 0 < ε → ∃ C : ℝ, 0 < C ∧ ∀ n : ℕ, 1 ≤ n → ‖f n‖ ≤ C * (n : ℝ) ^ ε

def complexPowReal (x : ℝ) (s : ℂ) : ℂ :=
  Complex.exp (s * Complex.log (x : ℂ))

def DirichletSeries (f : ℕ → ℂ) (s : ℂ) : ℂ :=
  ∑' n : ℕ, if h : 1 ≤ n then f n * Complex.exp (-s * Complex.log (n : ℂ)) else 0

def PerronVerticalIntegral (F : ℂ → ℂ) (x σ T : ℝ) : ℂ :=
  ∫ t in (-T)..T,
    (F ((σ : ℂ) + (t : ℂ) * Complex.I) *
        complexPowReal x ((σ : ℂ) + (t : ℂ) * Complex.I) /
        ((σ : ℂ) + (t : ℂ) * Complex.I)) *
      Complex.I

def PerronConstant : ℂ :=
  (1 : ℂ) / ((2 * Real.pi : ℂ) * Complex.I)

theorem perron_formula_subpolynomial_growth
    (f : ℕ → ℂ)
    (hf : SubpolynomialGrowth f)
    {x σ : ℝ}
    (hx_pos : 0 < x)
    (hx_nonint : ¬ ∃ n : ℕ, x = n)
    (hσ : 1 < σ)
    {L : ℂ}
    (hlim :
      Filter.Tendsto
        (fun T : ℝ => PerronVerticalIntegral (DirichletSeries f) x σ T)
        Filter.atTop
        (nhds L)) :
    Finset.sum (Finset.Icc 1 (Nat.floor x)) (fun n => f n) = PerronConstant * L := by
  sorry