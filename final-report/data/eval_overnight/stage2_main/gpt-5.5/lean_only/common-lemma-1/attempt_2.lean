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
  let A : ℝ → ℕ → Set α := fun ε n => {x | ε ≤ |fSeq (n + 1) x - f x|}
  have h_limsup : ∀ ε > 0, μ {x | ∃ᶠ n in Filter.atTop, x ∈ A ε n} = 0 := by
    intro ε hε
    have hs : Summable (fun n : ℕ => μ (A ε n)) := h ε hε
    have htail :
        Tendsto (fun N : ℕ => ∑' k : ℕ, μ (A ε (k + N))) atTop (nhds 0) := by
      simpa [add_comm, add_left_comm, add_assoc] using
        (tendsto_tsum_compl_atTop_zero (f := fun n : ℕ => μ (A ε n)) hs)
    refine le_antisymm ?_ (zero_le _)
    refine le_of_tendsto_of_tendsto' tendsto_const_nhds htail ?_
    intro N
    calc
      μ {x | ∃ᶠ n in Filter.atTop, x ∈ A ε n}
          ≤ μ (⋃ k : ℕ, A ε (k + N)) := by
              refine measure_mono ?_
              intro x hx
              simp only [Set.mem_iUnion]
              rw [frequently_atTop] at hx
              exact hx N
      _ ≤ ∑' k : ℕ, μ (A ε (k + N)) := by
              exact measure_iUnion_le (fun k : ℕ => A ε (k + N))
  refine ⟨?_, ?_⟩
  · intro ε hε
    simpa [A] using h_limsup ε hε
  · have hq :
        ∀ q : ℚ, 0 < q →
          ∀ᵐ x ∂μ, ¬ ∃ᶠ n in Filter.atTop, (q : ℝ) ≤ |fSeq (n + 1) x - f x| := by
      intro q hqpos
      have hμ :
          μ {x | ∃ᶠ n in Filter.atTop, (q : ℝ) ≤ |fSeq (n + 1) x - f x|} = 0 := by
        simpa [A] using h_limsup (q : ℝ) (by exact_mod_cast hqpos)
      rw [← ae_not_iff]
      exact ae_iff.mpr hμ
    have hq_all :
        ∀ᵐ x ∂μ,
          ∀ q : ℚ, 0 < q →
            ¬ ∃ᶠ n in Filter.atTop, (q : ℝ) ≤ |fSeq (n + 1) x - f x| := by
      simpa only [ae_all_iff] using hq
    filter_upwards [hq_all] with x hx
    rw [Metric.tendsto_atTop]
    intro ε hε
    obtain ⟨q, hq0, hqε⟩ : ∃ q : ℚ, 0 < q ∧ (q : ℝ) < ε := by
      obtain ⟨q, hq0, hqε⟩ := exists_rat_btwn hε
      exact ⟨q, by exact_mod_cast hq0, hqε⟩
    have hnotfreq := hx q hq0
    rw [not_frequently] at hnotfreq
    rw [eventually_atTop] at hnotfreq
    obtain ⟨N, hN⟩ := hnotfreq
    refine ⟨N + 1, ?_⟩
    intro n hn
    rcases n with _ | m
    · omega
    · have hm : N ≤ m := by omega
      have hm_lt : |fSeq (m + 1) x - f x| < (q : ℝ) := by
        have := hN m hm
        simpa [not_le] using this
      calc
        dist (fSeq (m + 1) x) (f x)
            = |fSeq (m + 1) x - f x| := by rw [Real.dist_eq]
        _ < (q : ℝ) := hm_lt
        _ < ε := hqε