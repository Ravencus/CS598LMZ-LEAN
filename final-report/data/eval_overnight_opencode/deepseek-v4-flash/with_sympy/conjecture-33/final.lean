import Mathlib

4
import Mathlib
open Set
open Real

theorem sequence_dense_in_unit_interval :
    Set.Icc (0 : ℝ) 1 ⊆
      closure
        (Set.range
          (fun n : ℕ => ((((2 : ℝ) / 3) + (((1 : ℝ) / 3) * Real.sin n)) ^ n))) := by
  have h1_mem : (1 : ℝ) ∈ Set.range (fun n : ℕ => (((2 : ℝ) / 3) + (((1 : ℝ) / 3) * Real.sin (n : ℝ))) ^ (n : ℕ)) := by
    refine ⟨0, ?_⟩
    norm_num
  have h0_mem : (0 : ℝ) ∈ closure (Set.range (fun n : ℕ => (((2 : ℝ) / 3) + (((1 : ℝ) / 3) * Real.sin (n : ℝ))) ^ (n : ℕ))) := by
    rw [Metric.mem_closure_iff]
    intro ε hε
    refine ⟨((2 : ℝ) / 3) ^ (4 : ℕ), ?_, ?_⟩
    · refine ⟨4, ?_⟩
      norm_num
    · calc
        |(0 : ℝ) - ((2 : ℝ) / 3) ^ (4 : ℕ)| = ((2 : ℝ) / 3) ^ (4 : ℕ) := by
          have hpos : 0 ≤ ((2 : ℝ) / 3) ^ (4 : ℕ) := by positivity
          rw [sub_zero, abs_of_nonneg hpos]
        _ = (16 / 81 : ℝ) := by norm_num
        _ < ε := by
          have : ((2 : ℝ) / 3) ^ (4 : ℕ) = (16 / 81 : ℝ) := by norm_num
          have : ((2 : ℝ) / 3) ^ (4 : ℕ) ≤ (2/3 : ℝ) ^ (2 : ℕ) := by
            refine pow_le_pow_right ?_ (by norm_num) (by omega)
            positivity
          sorry
    sorry
  sorry
  intro x hx
  rcases hx with ⟨hx1, hx2⟩
  have hx_nonneg : 0 ≤ x := hx1
  have hx_leq_one : x ≤ 1 := hx2
  by_cases hx_eq1 : x = 1
  · subst x
    exact Set.subset_closure h1_mem
  · by_cases hx_eq0 : x = 0
    · subst x
      exact h0_mem
    · have hx_pos : 0 < x := by
        by_contra hle
        push_neg at hle
        have : x ≤ 0 := hle
        have : x = 0 := le_antisymm this hx_nonneg
        exact hx_eq0 this
      have hx_lt1 : x < 1 := lt_of_le_of_ne hx_leq_one hx_eq1
      rw [Metric.mem_closure_iff]
      intro ε hε
      have hxpos : 0 < x := hx_pos
      have hx_lt1' : x < 1 := hx_lt1
      have : Filter.Tendsto (fun (n : ℕ) => (((2 : ℝ) / 3) + (((1 : ℝ) / 3) * Real.sin (n : ℝ))) ^ (n : ℕ)) Filter.atTop (𝓝 x) := by
        sorry
      have : ∃ (n : ℕ), dist (((2 : ℝ) / 3) + (((1 : ℝ) / 3) * Real.sin (n : ℝ))) ^ (n : ℕ) x < ε := by
        simpa [Metric.tendsto_nhds, Filter.Eventually, Filter.eventually_atTop] using this ε (by exact hε)
      rcases this with ⟨n, hn⟩
      refine ⟨(((2 : ℝ) / 3) + (((1 : ℝ) / 3) * Real.sin (n : ℝ))) ^ (n : ℕ), Set.mem_range_self n, hn⟩