import Mathlib

open Filter MeasureTheory

def ConvergesInMeasure
    {α β : Type*} [MeasurableSpace α] [PseudoMetricSpace β]
    (μ : Measure α) (f : ℕ → α → β) (g : α → β) : Prop :=
  ∀ ε : ℝ, 0 < ε →
    Tendsto (fun n => μ {x | ε ≤ dist (f n x) (g x)}) atTop (nhds (0 : ℝ≥0∞))

theorem convergenceInMeasure_iff_every_subsequence_has_ae_convergent_subsubsequence
    {α β : Type*}
    [MeasurableSpace α]
    [PseudoMetricSpace β]
    [MeasurableSpace β]
    [BorelSpace β]
    (μ : Measure α)
    (f : ℕ → α → β)
    (g : α → β)
    (hμ : μ Set.univ < ∞)
    (hf : ∀ n, Measurable (f n))
    (hg : Measurable g) :
    ConvergesInMeasure μ f g ↔
      ∀ n : ℕ → ℕ, StrictMono n →
        ∃ m : ℕ → ℕ, StrictMono m ∧
          (∀ᵐ x ∂μ, Tendsto (fun k => f (n (m k)) x) atTop (nhds (g x))) := by
  sorry