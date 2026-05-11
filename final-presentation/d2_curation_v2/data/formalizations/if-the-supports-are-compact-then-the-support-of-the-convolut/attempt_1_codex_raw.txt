import Mathlib

theorem compactSupport_mul_of_compactSupport
    {α β : Type*} [TopologicalSpace α] [MulZeroOneClass β]
    {f g : α → β}
    (hf : HasCompactSupport f) (hg : HasCompactSupport g) :
    HasCompactSupport (f * g) := by
  sorry