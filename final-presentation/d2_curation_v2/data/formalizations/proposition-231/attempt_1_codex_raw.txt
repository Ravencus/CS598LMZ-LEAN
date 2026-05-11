import Mathlib

open Set

def IsLimsupSeq (x : ℕ → ℝ) (U : ℝ) : Prop :=
  (∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N, x n < U + ε) ∧
    ∀ ε > 0, ∀ N : ℕ, ∃ n ≥ N, U - ε < x n

def IsLiminfSeq (x : ℕ → ℝ) (L : ℝ) : Prop :=
  (∀ ε > 0, ∃ N : ℕ, ∀ n ≥ N, L - ε < x n) ∧
    ∀ ε > 0, ∀ N : ℕ, ∃ n ≥ N, x n < L + ε

theorem continuous_monotone_limsup_liminf_of_sequence
    (x : ℕ → ℝ) (U L : ℝ) (I : Set ℝ) (f : ℝ → ℝ)
    (hx_bdd : ∃ M : ℝ, ∀ n : ℕ, |x n| ≤ M)
    (hU : IsLimsupSeq x U) (hL : IsLiminfSeq x L)
    (hLU : L ≤ U)
    (hI_open : IsOpen I) (hI_convex : Convex ℝ I)
    (hIcc : Set.Icc L U ⊆ I)
    (hf_cont : ContinuousOn f I) :
    ((MonotoneOn f I →
        IsLimsupSeq (fun n => f (x n)) (f U) ∧
        IsLiminfSeq (fun n => f (x n)) (f L)) ∧
      (AntitoneOn f I →
        IsLimsupSeq (fun n => f (x n)) (f L) ∧
        IsLiminfSeq (fun n => f (x n)) (f U))) := by
  sorry