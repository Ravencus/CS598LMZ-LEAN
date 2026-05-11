import Mathlib

open Filter

theorem real_sequence_tendsto_iff_eventually_pairwise_close
    (xSeq : ℕ → ℝ) (x : ℝ) :
    Filter.Tendsto xSeq Filter.atTop (nhds x) ↔
      ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |xSeq n - xSeq m| < ε := by
  constructor
  · intro h ε hε
    have hhalf : ε / 2 > 0 := by linarith
    have hconv : ∀ ε > 0, ∃ N, ∀ n ≥ N, |xSeq n - x| < ε := by
      have h' := (Metric.tendsto_atTop (α := ℝ)).mp h
      intro ε' hε'
      rcases h' ε' hε' with ⟨N, hN⟩
      refine ⟨N, ?_⟩
      intro n hn
      simpa [Real.dist_eq] using hN n hn
    rcases hconv (ε / 2) hhalf with ⟨N, hN⟩
    refine ⟨max N 1, by omega, ?_⟩
    intro n m hn hm
    have hnN : N ≤ n := by omega
    have hmN : N ≤ m := by omega
    have hx_n : |xSeq n - x| < ε / 2 := hN n hnN
    have hx_m : |xSeq m - x| < ε / 2 := hN m hmN
    calc
      |xSeq n - xSeq m| = |(xSeq n - x) - (xSeq m - x)| := by ring
      _ ≤ |xSeq n - x| + |xSeq m - x| := abs_sub _ _
      _ < ε / 2 + ε / 2 := by nlinarith
      _ = ε := by ring
  · intro h
    have hCauchy : CauchySeq xSeq := by
      rw [Metric.cauchy_iff]
      intro ε hε
      rcases h ε hε with ⟨N, hNpos, hN⟩
      refine ⟨N + 1, ?_⟩
      intro n m hn hm
      have hn' : N < n := by omega
      have hm' : N < m := by omega
      simpa [Real.dist_eq] using hN n m hn' hm'
    have h_cplt : ∃ (L : ℝ), Filter.Tendsto xSeq Filter.atTop (nhds L) :=
      cauchySeq_tendsto hCauchy
    rcases h_cplt with ⟨L, hL⟩
    have hL_conv : ∀ ε > 0, ∃ N, ∀ n ≥ N, |xSeq n - L| < ε := by
      have h' := (Metric.tendsto_atTop (α := ℝ)).mp hL
      intro ε hε
      rcases h' ε hε with ⟨N, hN⟩
      refine ⟨N, ?_⟩
      intro n hn
      simpa [Real.dist_eq] using hN n hn
    apply Metric.tendsto_atTop.mpr
    intro ε hε
    rcases hL_conv (ε / 2) (by linarith) with ⟨N, hN⟩
    rcases h ε hε with ⟨M, hMpos, hM⟩
    let N' := max N M + 1
    refine ⟨N', ?_⟩
    intro n hn
    have hnL : N ≤ n := by omega
    have hx_n_L : |xSeq n - L| < ε / 2 := hN n hnL
    have hx_n_M : ∀ m, M < m → |xSeq n - xSeq m| < ε := by
      intro m hm
      have hn' : N' - 1 < n := by omega
      have hm' : N' - 1 < m := by
        -- hm is N' ≤ m, but we need N' - 1 < m
        omega
      sorry
    sorry