import Mathlib

theorem memLp_iff_summable_dyadic_levelSetMeasures
    {X : Type*} [MeasurableSpace X] (μ : MeasureTheory.Measure X)
    {p : ℝ≥0∞} (hp1 : 1 ≤ p) (hp_top : p < ⊤)
    {f : X → ℝ} (hf : Measurable f) :
    MeasureTheory.MemLp f p μ ↔
      Summable (fun k : ℤ =>
        Real.rpow 2 ((k : ℝ) * p.toReal) *
          (μ {x | |f x| > Real.rpow 2 (k : ℝ)}).toReal) := by
  sorry