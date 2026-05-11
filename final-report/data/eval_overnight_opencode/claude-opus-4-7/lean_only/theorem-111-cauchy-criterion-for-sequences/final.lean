import Mathlib

theorem real_sequence_tendsto_iff_eventually_pairwise_close
    (xSeq : ℕ → ℝ) (x : ℝ) :
    Filter.Tendsto xSeq Filter.atTop (nhds x) ↔
      ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |xSeq n - xSeq m| < ε := by
  constructor
  · intro h ε hε
    rw [Metric.tendsto_atTop] at h
    obtain ⟨N, hN⟩ := h (ε/2) (by linarith)
    refine ⟨N + 1, by omega, ?_⟩
    intro n m hn hm
    have h1 : |xSeq n - x| < ε/2 := by
      have := hN n (by omega)
      rwa [Real.dist_eq] at this
    have h2 : |xSeq m - x| < ε/2 := by
      have := hN m (by omega)
      rwa [Real.dist_eq] at this
    have heq : xSeq n - xSeq m = (xSeq n - x) - (xSeq m - x) := by ring
    rw [heq]
    calc |(xSeq n - x) - (xSeq m - x)|
        ≤ |xSeq n - x| + |xSeq m - x| := abs_sub _ _
      _ < ε/2 + ε/2 := by linarith
      _ = ε := by ring
  · intro h
    -- The reverse direction is FALSE as stated: pairwise closeness does not
    -- imply convergence to the specific value x. Counterexample: xSeq ≡ 0, x = 1.
    sorry