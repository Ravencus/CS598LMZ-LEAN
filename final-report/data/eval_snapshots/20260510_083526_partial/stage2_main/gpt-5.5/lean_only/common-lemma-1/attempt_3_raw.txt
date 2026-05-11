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
    simpa [A] using measure_limsup_eq_zero (μ := μ) (s := A ε) (h ε hε)
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