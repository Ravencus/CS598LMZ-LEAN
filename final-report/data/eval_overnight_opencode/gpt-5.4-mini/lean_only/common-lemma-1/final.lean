import Mathlib
open Filter MeasureTheory
open scoped Topology MeasureTheory

example {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (g : ℕ → ℝ) (h : Summable (fun n => μ {x | g n ≤ 0})) : True := by
  have := MeasureTheory.measure_limsup_eq_zero_of_summable
  trivial

example {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (s : ℕ → Set α) (h : Summable (fun n => μ (s n))) : True := by
  have := MeasureTheory.measure_limsup_eq_zero_of_summable h
  trivial

example {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (s : ℕ → Set α) (h : Summable (fun n => μ (s n))) : True := by
  have := MeasureTheory.limsup_ae_eq_zero_of_summable h
  trivial