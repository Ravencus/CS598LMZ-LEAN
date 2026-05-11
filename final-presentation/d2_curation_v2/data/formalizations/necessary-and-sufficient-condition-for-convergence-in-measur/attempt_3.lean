import Mathlib

open Filter MeasureTheory

def ConvergesInMeasure
    {α β : Type*} [MeasurableSpace α] [PseudoMetricSpace β]
    (μ : Measure α) (f : ℕ → α → β) (g : α → β) : Prop :=
  ∀ ε : ℝ, 0 < ε →
    Filter.Tendsto
      (fun n : ℕ => μ (Set.setOf fun x : α => ε ≤ dist (f n x) (g x)))
      Filter.atTop
      (Filter.nhds (0 : ℝ≥0∞))

theorem convergenceInMeasure_iff_every_subsequence_has_ae_convergent_subsubsequence
    {α β : Type*}
    [MeasurableSpace α]
    [PseudoMetricSpace β]
    [MeasurableSpace β]
    [BorelSpace β]
    (μ : Measure α)
    (f : ℕ → α → β)
    (g : α → β)
    (hμ : μ Set.univ < (⊤ : ℝ≥0∞))
    (hf : ∀ n, Measurable (f n))
    (hg : Measurable g) :
    ConvergesInMeasure μ f g ↔
      ∀ n : ℕ → ℕ, StrictMono n →
        ∃ m : ℕ → ℕ, StrictMono m ∧
          Filter.Eventually
            (fun x : α =>
              Filter.Tendsto
                (fun k : ℕ => f (n (m k)) x)
                Filter.atTop
                (Filter.nhds (g x)))
            (Measure.ae μ) := by
  sorry