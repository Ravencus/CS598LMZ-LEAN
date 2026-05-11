import Mathlib

open Filter MeasureTheory
open scoped Topology MeasureTheory ENNReal

theorem summable_measure_limsup_null_ae_tendsto
    {α : Type*} [MeasurableSpace α] (μ : Measure α)
    (fSeq : ℕ → α → ℝ) (f : α → ℝ)
    (h :
      ∀ ε > 0, Summable (fun n : ℕ => μ {x | ε ≤ |fSeq (n + 1) x - f x|})) :
    (∀ ε > 0, μ {x | ∃ᶠ n in Filter.atTop, ε ≤ |fSeq (n + 1) x - f x|} = 0) ∧
      ∀ᵐ x ∂μ, Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (nhds (f x)) := by
  have part1 : ∀ ε > 0, μ {x | ∃ᶠ n in Filter.atTop, ε ≤ |fSeq (n + 1) x - f x|} = 0 := by
    intro ε hε
    have hsum := h ε hε
    have hne : (∑' n, μ {x | ε ≤ |fSeq (n + 1) x - f x|}) ≠ ⊤ := hsum.tsum_lt_top.ne
    have hlim := MeasureTheory.measure_limsup_atTop_eq_zero
      (s := fun n => {x | ε ≤ |fSeq (n + 1) x - f x|}) hne
    have heq : {x | ∃ᶠ n in Filter.atTop, ε ≤ |fSeq (n + 1) x - f x|} =
        Filter.limsup (fun n => {x | ε ≤ |fSeq (n + 1) x - f x|}) Filter.atTop := by
      ext x
      rw [Filter.mem_limsup]
      rfl
    rw [heq]; exact hlim
  refine ⟨part1, ?_⟩
  set N : ℕ → Set α := fun k =>
    {x | ∃ᶠ n in Filter.atTop, (1 : ℝ) / (k + 1) ≤ |fSeq (n + 1) x - f x|} with hNdef
  have hN : ∀ k, μ (N k) = 0 := fun k => part1 ((1 : ℝ) / (k + 1)) (by positivity)
  have hunion : μ (⋃ k, N k) = 0 := measure_iUnion_null hN
  refine measure_mono_null ?_ hunion
  intro x hx
  rw [Set.mem_compl_iff, Set.mem_setOf_eq] at hx
  rw [Set.mem_iUnion]
  by_contra hxn
  push_neg at hxn
  apply hx
  rw [Metric.tendsto_atTop]
  intro ε hε
  obtain ⟨k, hk⟩ := exists_nat_one_div_lt hε
  have hnotN : x ∉ N k := hxn k
  rw [hNdef] at hnotN
  simp only [Set.mem_setOf_eq] at hnotN
  rw [Filter.not_frequently] at hnotN
  rw [Filter.eventually_atTop] at hnotN
  obtain ⟨M, hM⟩ := hnotN
  refine ⟨M + 1, ?_⟩
  intro n hn
  obtain ⟨m, rfl⟩ : ∃ m, n = m + 1 := ⟨n - 1, by omega⟩
  have hmM : M ≤ m := by omega
  have hlt : ¬ ((1 : ℝ) / (k + 1) ≤ |fSeq (m + 1) x - f x|) := hM m hmM
  push_neg at hlt
  rw [Real.dist_eq]
  exact lt_trans hlt hk