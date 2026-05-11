import Mathlib

open MeasureTheory Topology

noncomputable section

def distributionFunction {α : Type*} [MeasurableSpace α] (μ : Measure α) (f : α → ℝ) (a : ℝ) : ℝ≥0∞ :=
  μ {x | a < |f x|}

theorem distributionFunction_properties
    {α : Type*} [MeasurableSpace α]
    (μ : Measure α) (f g h : α → ℝ) (F : ℕ → α → ℝ)
    (hf : Measurable f) (hg : Measurable g) (hh : Measurable h) (hF : ∀ n, Measurable (F n)) :
    Antitone (distributionFunction μ f) ∧
      (∀ a : ℝ,
        Filter.Tendsto (distributionFunction μ f) (nhdsWithin a (Set.Ioi a))
          (𝓝 (distributionFunction μ f a))) ∧
      (((∀ x, |f x| ≤ |g x|) → distributionFunction μ f ≤ distributionFunction μ g)) ∧
      (((Monotone fun n x => |F n x|) →
        (∀ x, Filter.Tendsto (fun n => |F n x|) Filter.atTop (𝓝 (|f x|))) →
        ∀ a : ℝ,
          Monotone (fun n => distributionFunction μ (F n) a) ∧
            Filter.Tendsto (fun n => distributionFunction μ (F n) a) Filter.atTop
              (𝓝 (distributionFunction μ f a)))) ∧
      (((∀ x, f x = g x + h x) →
        ∀ a : ℝ,
          distributionFunction μ f a ≤
            distributionFunction μ g (a / 2) + distributionFunction μ h (a / 2))) ∧
      (((∀ x, f x = g x * h x) →
        ∀ a : ℝ,
          distributionFunction μ f a ≤
            distributionFunction μ g (Real.sqrt (a / 2)) +
              distributionFunction μ h (Real.sqrt (a / 2)))) := by
  sorry