import Mathlib

theorem ae_tendsto_subseq_div
    {α : Type*} [MeasurableSpace α]
    (m : MeasureTheory.Measure α) (T : ℕ → α → ℝ) (n : ℕ → ℕ) (μ : α → ℝ) :
    ∀ᵐ x ∂m, Filter.Tendsto (fun k : ℕ => T (n k) x / (n k : ℝ)) Filter.atTop (Filter.nhds (μ x)) := by
  sorry