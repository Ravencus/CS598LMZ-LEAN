import Mathlib

theorem sequence_limit_unique {α : Type*} [TopologicalSpace α] [T2Space α]
    (u : ℕ → α) {l₁ l₂ : α}
    (h₁ : Filter.Tendsto u Filter.atTop (nhds l₁))
    (h₂ : Filter.Tendsto u Filter.atTop (nhds l₂)) :
    l₁ = l₂ := by
  sorry