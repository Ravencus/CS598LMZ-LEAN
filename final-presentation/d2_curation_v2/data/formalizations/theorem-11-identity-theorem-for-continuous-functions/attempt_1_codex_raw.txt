import Mathlib

theorem continuous_eq_of_eq_on_dense
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y] [T2Space Y]
    {f g : X → Y} (hf : Continuous f) (hg : Continuous g)
    {Z : Set X} (hZ : Dense Z) (hfg : ∀ x ∈ Z, f x = g x) :
    ∀ x : X, f x = g x := by
  sorry