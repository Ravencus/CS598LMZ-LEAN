import Mathlib

theorem continuous_le_of_dense_of_isClosed_le
    {X Y : Type*} [TopologicalSpace X] [Preorder Y] [TopologicalSpace Y] [T2Space Y]
    {f g : X → Y} (hf : Continuous f) (hg : Continuous g)
    {Z : Set X} (hZ : Dense Z)
    (hclosed : IsClosed {p : Y × Y | p.1 ≤ p.2})
    (hfg : ∀ x ∈ Z, f x ≤ g x) :
    ∀ x : X, f x ≤ g x := by
  sorry