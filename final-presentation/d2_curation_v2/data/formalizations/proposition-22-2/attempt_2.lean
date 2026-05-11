import Mathlib

theorem measurable_memLp_iff_summable_dyadic_level_sets
    {α : Type*} [MeasurableSpace α] (μ : MeasureTheory.Measure α) (p : ℕ) (hp : 1 ≤ p)
    (f : α → ℝ) (hf : Measurable f) :
    MeasureTheory.MemLp f (p : ℝ≥0∞) μ ↔
      Summable (fun k : ℤ =>
        ((2 : ℝ) ^ (k * (p : ℤ))) * (μ {x | |f x| > (2 : ℝ) ^ k}).toReal) := by
  sorry