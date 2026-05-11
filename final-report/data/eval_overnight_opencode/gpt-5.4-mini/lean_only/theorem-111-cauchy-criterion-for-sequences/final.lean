import Mathlib

theorem real_sequence_tendsto_iff_eventually_pairwise_close
    (xSeq : ℕ → ℝ) (x : ℝ) :
    Filter.Tendsto xSeq Filter.atTop (nhds x) ↔
      ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |xSeq n - xSeq m| < ε := by
  constructor
  · intro hx ε hε
    rcases (Metric.tendsto_nhds_iff.mp hx (ε / 2) (by linarith)) with ⟨N, hN⟩
    refine ⟨N + 1, by omega, ?_⟩
    intro n m hn hm
    have hn' : |xSeq n - x| < ε / 2 := hN n (by omega)
    have hm' : |xSeq m - x| < ε / 2 := hN m (by omega)
    have htri : |xSeq n - xSeq m| ≤ |xSeq n - x| + |xSeq m - x| := by
      calc
        |xSeq n - xSeq m| = |(xSeq n - x) + (x - xSeq m)| := by ring_nf
        _ ≤ |xSeq n - x| + |x - xSeq m| := by simpa using abs_add (xSeq n - x) (x - xSeq m)
        _ = |xSeq n - x| + |xSeq m - x| := by simp [abs_sub_comm]
    have hlt : |xSeq n - x| + |xSeq m - x| < ε := by
      linarith
    linarith
  · intro h
    have hc : CauchySeq xSeq := by
      rw [Metric.cauchySeq_iff]
      intro ε hε
      rcases h ε hε with ⟨N, hN, hpair⟩
      refine Filter.eventually_atTop.2 ?_
      refine ⟨N, ?_⟩
      intro n hn
      refine Filter.eventually_atTop.2 ?_
      refine ⟨N, ?_⟩
      intro m hm
      exact hpair n m hn hm
    exact cauchySeq_tendsto_of_complete hc
