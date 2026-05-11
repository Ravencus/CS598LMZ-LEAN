import Mathlib

open Filter MeasureTheory
open scoped Topology MeasureTheory

theorem summable_measure_limsup_null_ae_tendsto
    {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (fSeq : ℕ → α → ℝ) (f : α → ℝ)
    (h :
      ∀ ε > 0, Summable (fun n : ℕ => μ {x | ε ≤ |fSeq (n + 1) x - f x|})) :
    (∀ ε > 0, μ {x | ∃ᶠ n in Filter.atTop, ε ≤ |fSeq (n + 1) x - f x|} = 0) ∧
      ∀ᵐ x ∂μ, Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (nhds (f x)) := by
  sorry