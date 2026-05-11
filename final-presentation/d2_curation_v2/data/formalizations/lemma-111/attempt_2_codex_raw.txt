import Mathlib

open Matrix

def MatricesAreSimilar {n : Type*} [Fintype n] [DecidableEq n]
    (M N : Matrix n n ℂ) : Prop :=
  ∃ P : Matrix n n ℂ, Invertible P ∧ (P * M = N * P ∨ P * N = M * P)

theorem ab_ba_are_similar_if_left_or_right_invertible
    {n : Type*} [Fintype n] [DecidableEq n]
    (A B : Matrix n n ℂ)
    (h : Invertible A ∨ Invertible B) :
    MatricesAreSimilar (A * B) (B * A) := by
  sorry