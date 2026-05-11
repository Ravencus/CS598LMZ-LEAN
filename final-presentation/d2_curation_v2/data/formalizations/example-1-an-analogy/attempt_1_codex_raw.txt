import Mathlib

theorem exists_orderings_minimizing_dot_product :
    ∃ b h : Fin 3 → ℕ,
      Set.BijOn b (Set.univ : Set (Fin 3)) ({1, 2, 3} : Set ℕ) ∧
      Set.BijOn h (Set.univ : Set (Fin 3)) ({4, 5, 6} : Set ℕ) ∧
      ∀ b' h' : Fin 3 → ℕ,
        Set.BijOn b' (Set.univ : Set (Fin 3)) ({1, 2, 3} : Set ℕ) →
        Set.BijOn h' (Set.univ : Set (Fin 3)) ({4, 5, 6} : Set ℕ) →
        (Finset.univ.sum fun i : Fin 3 => b i * h i) ≤
          Finset.univ.sum (fun i : Fin 3 => b' i * h' i) := by
  sorry