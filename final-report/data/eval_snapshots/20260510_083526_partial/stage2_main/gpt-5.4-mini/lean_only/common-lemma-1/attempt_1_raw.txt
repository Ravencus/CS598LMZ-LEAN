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
  have hnull :
      ∀ ε > 0, μ {x | ∃ᶠ n in Filter.atTop, ε ≤ |fSeq (n + 1) x - f x|} = 0 := by
    intro ε hε
    have hlim :
        μ (Set.limsup (fun n : ℕ => {x | ε ≤ |fSeq (n + 1) x - f x|}) Filter.atTop) = 0 := by
      simpa using
        (measure_limsup_eq_zero_of_summable (μ := μ)
          (s := fun n : ℕ => {x | ε ≤ |fSeq (n + 1) x - f x|})
          (h ε hε))
    simpa [Set.limsup] using hlim

  have hae :
      ∀ᵐ x ∂μ, Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (nhds (f x)) := by
    let bad : ℕ → Set α :=
      fun n => {x | ∃ᶠ m in Filter.atTop, (1 / (n + 1 : ℝ)) ≤ |fSeq (m + 1) x - f x|}

    have hbad : ∀ n : ℕ, μ (bad n) = 0 := by
      intro n
      have hpos : 0 < (1 / (n + 1 : ℝ)) := by positivity
      simpa [bad] using hnull (1 / (n + 1 : ℝ)) hpos

    have hunion : μ (⋃ n : ℕ, bad n) = 0 := by
      have hle : μ (⋃ n : ℕ, bad n) ≤ ∑' n : ℕ, μ (bad n) := measure_iUnion_le fun n => bad n
      calc
        μ (⋃ n : ℕ, bad n) ≤ ∑' n : ℕ, μ (bad n) := hle
        _ = 0 := by simp [hbad]

    have hconv_of_notin :
        ∀ x : α, x ∉ ⋃ n : ℕ, bad n →
          Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (nhds (f x)) := by
      intro x hx
      rw [Metric.tendsto_atTop]
      intro ε hε
      rcases Real.exists_nat_one_div_lt hε with ⟨N, hN⟩

      have hgood_shift : ∀ᶠ m in Filter.atTop, |fSeq (m + 1) x - f x| < 1 / (N + 1 : ℝ) := by
        have hnotfreq : ¬ ∃ᶠ m in Filter.atTop, (1 / (N + 1 : ℝ)) ≤ |fSeq (m + 1) x - f x| := by
          have hnotbadN : x ∉ bad N := by
            intro hxN
            exact hx (by
              exact mem_iUnion.mpr ⟨N, hxN⟩)
          simpa [bad] using hnotbadN
        simpa [Filter.frequently_iff, not_le] using hnotfreq

      rw [Filter.eventually_atTop] at hgood_shift
      rcases hgood_shift with ⟨M, hM⟩
      rw [Filter.eventually_atTop]
      refine ⟨M + 1, ?_⟩
      intro n hn
      have hn' : M ≤ n - 1 := by omega
      have hsmall : |fSeq ((n - 1) + 1) x - f x| < 1 / (N + 1 : ℝ) := hM (n - 1) hn'
      have hEq : (n - 1) + 1 = n := by omega
      have hlt : |fSeq n x - f x| < 1 / (N + 1 : ℝ) := by
        simpa [hEq] using hsmall
      exact lt_of_lt_of_le hlt (le_of_lt hN)

    have hsubset :
        {x : α | ¬ Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (nhds (f x))} ⊆
          ⋃ n : ℕ, bad n := by
      intro x hx
      by_contra hxU
      exact hx (hconv_of_notin x hxU)

    have hzero : μ {x : α | ¬ Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (nhds (f x))} = 0 := by
      have hle : μ {x : α | ¬ Tendsto (fun n : ℕ => fSeq n x) Filter.atTop (nhds (f x))} ≤ μ (⋃ n : ℕ, bad n) :=
        measure_mono hsubset
      exact le_antisymm (le_trans hle hunion) bot_le

    rw [ae_iff]
    simpa using hzero

  exact ⟨hnull, hae⟩