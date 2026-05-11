import Mathlib

open MeasureTheory Filter Set
open scoped Topology

def distributionFunction {α : Type*} [MeasurableSpace α] (μ : Measure α) (f : α → ℝ) :
    ℝ → ENNReal :=
  fun a => μ {x | |f x| > a}

theorem distributionFunction_properties
    {α : Type*} [MeasurableSpace α] (μ : Measure α) :
    (∀ f : α → ℝ,
      Antitone (distributionFunction μ f) ∧
      ∀ a : ℝ, ContinuousWithinAt (distributionFunction μ f) (Set.Ici a) a) ∧
    (∀ f g : α → ℝ, (∀ x, |f x| ≤ |g x|) →
      distributionFunction μ f ≤ distributionFunction μ g) ∧
    (∀ (F : ℕ → α → ℝ) (f : α → ℝ),
      (∀ x, Monotone (fun n => |F n x|)) →
      (∀ x, Filter.Tendsto (fun n => |F n x|) Filter.atTop (nhds (|f x|))) →
      (∀ a : ℝ, Monotone (fun n => distributionFunction μ (F n) a)) ∧
      ∀ a : ℝ,
        Filter.Tendsto (fun n => distributionFunction μ (F n) a) Filter.atTop
          (nhds (distributionFunction μ f a))) ∧
    (∀ f g h : α → ℝ, f = g + h →
      ∀ a : ℝ,
        distributionFunction μ f a ≤
          distributionFunction μ g (a / 2) + distributionFunction μ h (a / 2)) ∧
    (∀ f g h : α → ℝ, f = g * h →
      ∀ a : ℝ,
        distributionFunction μ f a ≤
          distributionFunction μ g (Real.sqrt (a / 2)) +
            distributionFunction μ h (Real.sqrt (a / 2))) := by
  sorry