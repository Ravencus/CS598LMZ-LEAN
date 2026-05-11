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
  classical
  have h_limsup :
      ∀ ε > 0, μ {x | ∃ᶠ n in Filter.atTop, ε ≤ |fSeq (n + 1) x - f x|} = 0 := by
    intro ε hε
    exact measure_setOf_frequently_eq_zero (μ := μ)
      (s := fun n : ℕ => {x | ε ≤ |fSeq (n + 1) x - f x|}) (h ε hε)
  refine ⟨h_limsup, ?_⟩
  have h_ae :
      ∀ᵐ x ∂μ, ∀ k : ℕ,
        ¬ ∃ᶠ n in Filter.atTop,
          (1 : ℝ) / (k + 1 : ℝ) ≤ |fSeq (n + 1) x - f x| := by
    refine ae_all_iff.mpr ?_
    intro k
    have hkpos : (0 : ℝ) < (1 : ℝ) / (k + 1 : ℝ) := by positivity
    have hz := h_limsup ((1 : ℝ) / (k + 1 : ℝ)) hkpos
    exact ae_iff.mpr (by simpa [Set.compl_setOf] using hz)
  filter_upwards [h_ae] with x hx
  rw [Metric.tendsto_nhds]
  intro ε hε
  obtain ⟨k, hk⟩ : ∃ k : ℕ, (1 : ℝ) / (k + 1 : ℝ) < ε := by
    obtain ⟨m, hm⟩ := exists_nat_one_div_lt hε
    exact ⟨m, by simpa [one_div] using hm⟩
  have hnot := hx k
  rw [not_frequently] at hnot
  have hev :
      ∀ᶠ n in Filter.atTop,
        ¬ (1 : ℝ) / (k + 1 : ℝ) ≤ |fSeq (n + 1) x - f x| := hnot
  obtain ⟨N, hN⟩ := eventually_atTop.1 hev
  refine eventually_atTop.2 ⟨N + 1, ?_⟩
  intro n hn
  cases n with
  | zero =>
      omega
  | succ m =>
      have hmN : N ≤ m := by omega
      have hm := hN m hmN
      rw [Real.dist_eq]
      exact (lt_of_not_ge hm).trans hk