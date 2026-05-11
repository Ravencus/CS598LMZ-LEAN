import Mathlib

theorem real_sequence_tendsto_iff_eventually_pairwise_close
    (xSeq : ℕ → ℝ) (x : ℝ) :
    Filter.Tendsto xSeq Filter.atTop (nhds x) ↔
      ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |xSeq n - xSeq m| < ε := by
  constructor
  · intro h ε hε
    have hhalf : ε/2 > 0 := by linarith
    rw [Metric.tendsto_atTop] at h
    sorry
  · intro h
    sorry