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
  constructor
  · intro ε hε
    have hsum := h ε hε
    have hts : (∑' n : ℕ, μ {x | ε ≤ |fSeq (n + 1) x - f x|}) ≠ (⊤ : ENNReal) := by
      simpa using hsum.tsum_ne_top
    simpa using
      (MeasureTheory.measure_setOf_frequently_eq_zero
        (μ := μ)
        (p := fun n x => ε ≤ |fSeq (n + 1) x - f x|)
        hts)
  · have hgood :
        ∀ n : ℕ, ∀ᵐ x ∂μ, ∀ᶠ m in Filter.atTop,
          |fSeq (m + 1) x - f x| < 1 / (n + 1 : ℝ) := by
      intro n
      have hsum :=
        h (1 / (n + 1 : ℝ)) (by positivity)
      have hts :
          (∑' m : ℕ, μ {x | 1 / (n + 1 : ℝ) ≤ |fSeq (m + 1) x - f x|}) ≠ (⊤ : ENNReal) := by
        simpa using hsum.tsum_ne_top
      simpa [Set.mem_setOf_eq, not_le] using
        (MeasureTheory.ae_eventually_notMem
          (μ := μ)
          (s := fun m : ℕ => {x | 1 / (n + 1 : ℝ) ≤ |fSeq (m + 1) x - f x|})
          hts)
    have htail : ∀ᵐ x ∂μ, Tendsto (fun n : ℕ => fSeq (n + 1) x) Filter.atTop (nhds (f x)) := by
      filter_upwards [ae_all_iff.2 hgood] with x hx
      refine Metric.tendsto_nhds.2 ?_
      intro ε hε
      rcases exists_nat_gt (1 / ε) with ⟨n, hn⟩
      have h1 : 1 < ε * n := by
        have hmul := mul_lt_mul_of_pos_right hn hε
        simpa [div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc] using hmul
      have h2 : ε * n < ε * (n + 1 : ℝ) := by
        have hn' : (n : ℝ) < n + 1 := by norm_num
        exact mul_lt_mul_of_pos_left hn' hε
      have hlarge : 1 < ε * (n + 1 : ℝ) := by linarith
      have hlt : 1 / (n + 1 : ℝ) < ε := by
        have hposn : 0 < (n + 1 : ℝ) := by positivity
        rw [div_lt_iff hposn]
        exact hlarge
      exact (hx n).mono fun m hm => lt_trans hm hlt
    exact (tendsto_add_atTop_iff_nat 1).1 htail