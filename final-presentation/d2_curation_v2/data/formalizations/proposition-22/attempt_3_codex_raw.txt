import Mathlib

open scoped ENNReal
open MeasureTheory

theorem memLp_iff_summable_dyadic_levelSetMeasures
    {X : Type*} [MeasurableSpace X] (μ : Measure X)
    {p : ENNReal} (hp1 : 1 ≤ p) (hp_top : p < ⊤)
    {f : X → ℝ} (hf : Measurable f) :
    MemLp f p μ ↔
      Summable (fun k : ℤ =>
        Real.rpow (2 : ℝ) ((k : ℝ) * ENNReal.toReal p) *
          (μ ({x | abs (f x) > Real.rpow (2 : ℝ) (k : ℝ)})).toReal) := by
  sorry