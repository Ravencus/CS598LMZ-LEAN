import Mathlib

theorem subsequence_convergence_implies_sequence_convergence
    {α : Type*} [TopologicalSpace α]
    (yseq : ℕ → α) (y : α)
    (h :
      ∀ n : ℕ → ℕ, StrictMono n →
        ∃ k : ℕ → ℕ, StrictMono k ∧
          Filter.Tendsto (fun m => yseq (n (k m))) Filter.atTop (𝓝 y)) :
    Filter.Tendsto yseq Filter.atTop (𝓝 y) := by
  sorry