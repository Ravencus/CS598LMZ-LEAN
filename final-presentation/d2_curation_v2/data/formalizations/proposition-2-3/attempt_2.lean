import Mathlib

theorem homeomorph_precompose_memC0
    {X Y : Type*}
    [TopologicalSpace X] [TopologicalSpace Y]
    (h : Homeomorph Y X) (f : ZeroAtInftyContinuousMap X ℂ) :
    ∃ g : ZeroAtInftyContinuousMap Y ℂ, ∀ y : Y, g y = f (h y) := by
  sorry