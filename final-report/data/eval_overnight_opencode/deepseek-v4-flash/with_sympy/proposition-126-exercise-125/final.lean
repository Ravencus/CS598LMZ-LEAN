import Mathlib

theorem subsequence_has_same_limit
    {α : Type*} [TopologicalSpace α] {u : ℕ → α} {l : α}
    (hu : Filter.Tendsto u Filter.atTop (nhds l)) :
    ∀ φ : ℕ → ℕ, StrictMono φ →
      ∃ m : α, Filter.Tendsto (fun n => u (φ n)) Filter.atTop (nhds m) ∧ m = l := by
  intro φ hmono
  use l
  constructor
  · have hφ_tendsto : Filter.Tendsto φ Filter.atTop Filter.atTop :=
      hmono.tendsto_atTop
    exact hu.comp hφ_tendsto
  · rfl