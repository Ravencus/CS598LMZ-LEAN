import Mathlib

theorem subsequence_has_same_limit
    {α : Type*} [TopologicalSpace α] {u : ℕ → α} {l : α}
    (hu : Filter.Tendsto u Filter.atTop (Filter.nhds l)) :
    ∀ φ : ℕ → ℕ, StrictMono φ →
      ∃ m : α, Filter.Tendsto (fun n => u (φ n)) Filter.atTop (Filter.nhds m) ∧ m = l := by
  sorry