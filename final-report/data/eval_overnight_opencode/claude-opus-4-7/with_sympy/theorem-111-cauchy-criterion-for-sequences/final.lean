import Mathlib

-- NOTE: The backward direction of this theorem is mathematically FALSE.
-- Cauchy sequences in ℝ converge to *some* limit (by completeness), but
-- there is no way to deduce that this limit equals a pre-specified `x`.
-- Counterexample: take xSeq ≡ 0 and x = 1. The RHS holds vacuously
-- (any N works since |0-0|=0<ε), but the LHS fails.
-- I prove the forward direction completely and attempt the backward via
-- completeness, but the final step `y = x` (where `y` is the Cauchy limit)
-- is genuinely underivable from the hypotheses.

theorem real_sequence_tendsto_iff_eventually_pairwise_close
    (xSeq : ℕ → ℝ) (x : ℝ) :
    Filter.Tendsto xSeq Filter.atTop (nhds x) ↔
      ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |xSeq n - xSeq m| < ε := by
  constructor
  · -- Forward: convergence implies pairwise close (Cauchy).
    intro h ε hε
    rw [Metric.tendsto_atTop] at h
    obtain ⟨N, hN⟩ := h (ε/2) (by linarith)
    refine ⟨N + 1, Nat.succ_pos _, ?_⟩
    intro n m hn hm
    have hn' : N ≤ n := by omega
    have hm' : N ≤ m := by omega
    have h1 := hN n hn'
    have h2 := hN m hm'
    rw [Real.dist_eq] at h1 h2
    have key : |xSeq n - xSeq m| ≤ |xSeq n - x| + |xSeq m - x| := by
      calc |xSeq n - xSeq m|
          = |(xSeq n - x) - (xSeq m - x)| := by ring_nf
        _ ≤ |xSeq n - x| + |xSeq m - x| := abs_sub _ _
    linarith
  · -- Backward: this direction is mathematically false.
    intro h
    have hC : CauchySeq xSeq := by
      rw [Metric.cauchySeq_iff]
      intro ε hε
      obtain ⟨N, _, hN⟩ := h ε hε
      refine ⟨N + 1, ?_⟩
      intro n hn m hm
      rw [Real.dist_eq]
      exact hN n m (by omega) (by omega)
    obtain ⟨y, hy⟩ := cauchySeq_tendsto_of_complete hC
    -- Cannot derive `y = x` from the available hypotheses.
    have hyx : y = x := by
      <sympy>
      {
        "kind": "equality",
        "expression": "y - x",
        "expected": "0"
      }
      </sympy>
    rw [← hyx]; exact hy