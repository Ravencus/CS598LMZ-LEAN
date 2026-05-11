import Mathlib

set_option linter.unusedVariables false
set_option linter.unusedSimpArgs false

open Filter MeasureTheory
open scoped Topology MeasureTheory

theorem summable_measure_limsup_null_ae_tendsto
    {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (fSeq : ℕ → α → ℝ) (f : α → ℝ)
    (h :
      ∀ ε > 0, Summable (fun n : ℕ => μ {x | ε ≤ |fSeq (n + 1) x - f x|})) :
    (∀ ε > 0, μ {x | ∃ᶠ n in Filter.atTop, ε ≤ |fSeq (n + 1) x - f x|} = 0) ∧
      ∀ᵐ x ∂μ, Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (nhds (f x)) := by
  have part1 : ∀ ε > 0, μ {x | ∃ᶠ n in Filter.atTop, ε ≤ |fSeq (n + 1) x - f x|} = 0 := by
    intro ε hε
    exact MeasureTheory.measure_setOf_frequently_eq_zero (h ε hε).tsum_lt_top.ne
  refine ⟨part1, ?_⟩
  have hae : ∀ k : ℕ, ∀ᵐ x ∂μ, ∀ᶠ n in atTop, |fSeq (n + 1) x - f x| < (1 : ℝ)/(k+1) := by
    intro k
    have hpos : (0 : ℝ) < 1/(k+1) := by positivity
    have hp := part1 (1/(k+1)) hpos
    rw [ae_iff]
    refine measure_mono_null ?_ hp
    intro x hx
    simp only [Set.mem_setOf_eq, not_eventually, not_lt] at hx
    exact hx
  have hae' := ae_all_iff.mpr hae
  filter_upwards [hae'] with x hx
  rw [Metric.tendsto_atTop]
  intro ε hε
  obtain ⟨k, hk⟩ := exists_nat_one_div_lt hε
  have hxk := hx k
  rw [Filter.eventually_atTop] at hxk
  obtain ⟨N, hN⟩ := hxk
  refine ⟨N + 1, ?_⟩
  intro n hn
  have hn' : n - 1 ≥ N := by omega
  have hbd := hN (n - 1) hn'
  have hrw : n - 1 + 1 = n := by omega
  rw [hrw] at hbd
  rw [Real.dist_eq]
  linarith