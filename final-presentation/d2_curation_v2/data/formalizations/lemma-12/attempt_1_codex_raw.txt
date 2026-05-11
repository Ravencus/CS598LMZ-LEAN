import Mathlib

theorem continuous_image_dense_in_range
    {X Y : Type*} [TopologicalSpace X] [TopologicalSpace Y]
    (f : X → Y) (hf : Continuous f) {E : Set X} (hE : Dense E) :
    Dense ({y : Set.range f | y.1 ∈ f '' E} : Set (Set.range f)) := by
  sorry