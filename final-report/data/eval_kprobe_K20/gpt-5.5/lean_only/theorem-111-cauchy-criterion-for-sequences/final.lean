import Mathlib

example : ¬ (∀ (xSeq : ℕ → ℝ) (x : ℝ),
    Filter.Tendsto xSeq Filter.atTop (nhds x) ↔
      ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |xSeq n - xSeq m| < ε) := by
  intro h
  have hiff := h (fun _ : ℕ => (0 : ℝ)) (1 : ℝ)
  have hrhs : ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |(fun _ : ℕ => (0 : ℝ)) n - (fun _ : ℕ => (0 : ℝ)) m| < ε := by
    intro ε hε
    refine ⟨1, by norm_num, ?_⟩
    intro n m hn hm
    simpa using hε
  have hbad : Filter.Tendsto (fun _ : ℕ => (0 : ℝ)) Filter.atTop (nhds (1 : ℝ)) := hiff.mpr hrhs
  have hzero : Filter.Tendsto (fun _ : ℕ => (0 : ℝ)) Filter.atTop (nhds (0 : ℝ)) := tendsto_const_nhds
  have hone : (1 : ℝ) = 0 := tendsto_nhds_unique hbad hzero
  norm_num at hone