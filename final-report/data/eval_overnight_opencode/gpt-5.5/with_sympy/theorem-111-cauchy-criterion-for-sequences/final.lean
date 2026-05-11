import Mathlib

example : ¬ (∀ (xSeq : ℕ → ℝ) (x : ℝ),
    Filter.Tendsto xSeq Filter.atTop (nhds x) ↔
      ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |xSeq n - xSeq m| < ε) := by
  intro h
  let z : ℕ → ℝ := fun _ => 0
  have hpair : ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m → |z n - z m| < ε := by
    intro ε hε
    refine ⟨1, by norm_num, ?_⟩
    intro n m hn hm
    simp [z, hε]
  have hz : Filter.Tendsto z Filter.atTop (nhds (1 : ℝ)) := (h z 1).2 hpair
  have hzero : Filter.Tendsto z Filter.atTop (nhds (0 : ℝ)) := by
    simp [z]
  have hlim : (1 : ℝ) = 0 := tendsto_nhds_unique hz hzero
  norm_num at hlim