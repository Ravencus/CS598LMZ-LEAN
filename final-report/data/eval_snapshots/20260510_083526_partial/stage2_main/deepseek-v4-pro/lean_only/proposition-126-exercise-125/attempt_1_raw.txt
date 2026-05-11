import Mathlib

theorem subsequence_has_same_limit
    {α : Type*} [TopologicalSpace α] {u : ℕ → α} {l : α}
    (hu : Filter.Tendsto u Filter.atTop (nhds l)) :
    ∀ φ : ℕ → ℕ, StrictMono φ →
      ∃ m : α, Filter.Tendsto (fun n => u (φ n)) Filter.atTop (nhds m) ∧ m = l := by
  intro φ hφ
  exact ⟨l, hu.comp hφ.tendsto_atTop, rfl⟩