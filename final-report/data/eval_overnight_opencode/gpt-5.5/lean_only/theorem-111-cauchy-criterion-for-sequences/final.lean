import Mathlib

example : ¬ (Filter.Tendsto (fun _ : ℕ => (0 : ℝ)) Filter.atTop (nhds (1 : ℝ)) ↔
      ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m →
        |(fun _ : ℕ => (0 : ℝ)) n - (fun _ : ℕ => (0 : ℝ)) m| < ε) := by
  intro h
  have hright : ∀ ε > 0, ∃ N : ℕ, 0 < N ∧ ∀ n m : ℕ, N < n → N < m →
      |(fun _ : ℕ => (0 : ℝ)) n - (fun _ : ℕ => (0 : ℝ)) m| < ε := by
    intro ε hε
    refine ⟨1, by norm_num, ?_⟩
    intro n m hn hm
    simpa using hε
  have hleft := h.mpr hright
  have hconst : Filter.Tendsto (fun _ : ℕ => (0 : ℝ)) Filter.atTop (nhds (0 : ℝ)) :=
    tendsto_const_nhds
  have hx : (0 : ℝ) = 1 := tendsto_nhds_unique hconst hleft
  norm_num at hx