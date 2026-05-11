import Mathlib

theorem real_sequence_tendsto_iff_eventually_pairwise_close
    (xSeq : ℕ → ℝ) (x : ℝ) :
    Filter.Tendsto xSeq Filter.atTop (nhds x) ↔
      ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |xSeq n - xSeq m| < ε := by
  constructor
  · intro h ε hε
    have h1 : ∀ᶠ n in Filter.atTop, |xSeq n - x| < ε / 2 := by
      simpa [Real.dist_eq] using (Metric.tendsto_nhds_iff.mp h (ε / 2) (by linarith))
    rcases (Filter.eventually_atTop.1 h1) with ⟨N, hN⟩
    refine ⟨N + 1, by omega, ?_⟩
    intro n m hn hm
    have hn' : N ≤ n := by omega
    have hm' : N ≤ m := by omega
    have hnx : |xSeq n - x| < ε / 2 := hN n hn'
    have hmx : |xSeq m - x| < ε / 2 := hN m hm'
    have htri : |xSeq n - xSeq m| ≤ |xSeq n - x| + |xSeq m - x| := by
      have := abs_sub_le (xSeq n) x (xSeq m)
      linarith
    linarith
  · intro h
    rw [Metric.tendsto_nhds_iff]
    intro ε hε
    rcases h ε hε with ⟨N, hNpos, hN⟩
    have htail : ∀ᶠ n in Filter.atTop, |xSeq n - x| < ε / 2 := by
      refine Filter.eventually_atTop.2 ?_
      refine ⟨N, ?_⟩
      intro n hn
      have hnm := hN n N hn (by omega)
      have hxx : |xSeq n - x| = |xSeq n - xSeq N + (xSeq N - x)| := by ring_nf
      have htri : |xSeq n - x| ≤ |xSeq n - xSeq N| + |xSeq N - x| := by
        have := abs_add (xSeq n - xSeq N) (xSeq N - x)
        nlinarith
      have hN' : |xSeq N - x| < ε / 2 := by
        have h' := hN N N (by omega) (by omega)
        linarith
      linarith
    simpa [Real.dist_eq] using htail
