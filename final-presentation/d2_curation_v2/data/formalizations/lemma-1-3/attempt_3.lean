import Mathlib

abbrev MyDualCharacter (G : Type*) [CommGroup G] [TopologicalSpace G] :=
  { χ : ContinuousMonoidHom G ℂ // ∀ x : G, ‖χ x‖ = 1 }

theorem exists_bad_real_part_outside_set
    {G : Type*} [CommGroup G] [TopologicalSpace G]
    [LocallyCompactSpace G] [T2Space G]
    {U : Set G} (hU : U ∈ 𝓝 (1 : G)) :
    ∃ K : Set (MyDualCharacter G),
      ∀ χ : MyDualCharacter G,
        χ ∉ K →
        ∃ x ∈ U, Complex.re (χ.1 x) ≤ 0 := by
  sorry