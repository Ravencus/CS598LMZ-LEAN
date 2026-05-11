import Mathlib

open Set

def tailSet (x : ℕ → ℝ) (n : ℕ) : Set ℝ :=
  {y | ∃ m : ℕ, n ≤ m ∧ x m = y}

noncomputable def seqLimsup (x : ℕ → ℝ) : ℝ :=
  sInf (Set.range fun n : ℕ => sSup (tailSet x n))

noncomputable def seqLiminf (x : ℕ → ℝ) : ℝ :=
  sSup (Set.range fun n : ℕ => sInf (tailSet x n))

theorem continuous_monotone_seq_limsup_liminf
    (x : ℕ → ℝ) (f : ℝ → ℝ) (I : Set ℝ) (L U : ℝ)
    (hx_bdd_above : BddAbove (Set.range x))
    (hx_bdd_below : BddBelow (Set.range x))
    (hL : seqLiminf x = L)
    (hU : seqLimsup x = U)
    (hLU : L ≤ U)
    (hI_open : IsOpen I)
    (hI_convex : Convex ℝ I)
    (hI_contains : Set.Icc L U ⊆ I)
    (hf_cont : ContinuousOn f I) :
    ((MonotoneOn f I) →
      seqLimsup (fun n => f (x n)) = f U ∧
      seqLiminf (fun n => f (x n)) = f L) ∧
    ((AntitoneOn f I) →
      seqLimsup (fun n => f (x n)) = f L ∧
      seqLiminf (fun n => f (x n)) = f U) := by
  sorry