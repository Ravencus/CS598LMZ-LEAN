import Mathlib

open MeasureTheory Filter Topology

def AEConvergesTo {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (f : ℕ → α → ℝ) (g : α → ℝ) : Prop :=
  ∀ᵐ x ∂μ, Tendsto (fun n : ℕ => f n x) atTop (nhds (g x))

def ConvergesInMeasure {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (f : ℕ → α → ℝ) (g : α → ℝ) : Prop :=
  ∀ ε : ℝ, ε > 0 →
    Tendsto (fun n : ℕ => μ ({x : α | ε ≤ dist (f n x) (g x)} : Set α)) atTop
      (nhds (0 : ℝ≥0∞))

theorem ae_convergence_implies_convergence_in_measure_of_finite_measure
    {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (hμ : μ Set.univ < (∞ : ℝ≥0∞)) {f : ℕ → α → ℝ} {g : α → ℝ}
    (hfg : AEConvergesTo μ f g) :
    ConvergesInMeasure μ f g := by
  sorry