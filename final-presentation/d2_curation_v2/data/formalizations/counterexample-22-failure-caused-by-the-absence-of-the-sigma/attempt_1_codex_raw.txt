import Mathlib

noncomputable section

open MeasureTheory

def I : Set ℝ := Set.Icc 0 1

def μ : Measure ℝ := volume.restrict I

def ν : Measure ℝ := Measure.count.restrict I

def D : Set (ℝ × ℝ) := {p | p.1 = p.2}

theorem diagonal_indicator_counting_measure_failure :
    (∫ z, Set.indicator D (fun _ : ℝ × ℝ => (1 : ℝ)) z ∂(μ.prod ν)) = 0 ∧
    (∫ y, ∫ x, Set.indicator D (fun _ : ℝ × ℝ => (1 : ℝ)) (x, y) ∂μ ∂ν) = 0 ∧
    (∫ x, ∫ y, Set.indicator D (fun _ : ℝ × ℝ => (1 : ℝ)) (x, y) ∂ν ∂μ) = 1 ∧
    ¬ SigmaFinite ν := by
  sorry