import Mathlib

open scoped BigOperators

def closedRectangle {n : ℕ} (a b : Fin n → ℝ) : Set (Fin n → ℝ) :=
  Set.Icc a b

def RiemannIntegrableOnRectangle {n : ℕ} (f : (Fin n → ℝ) → ℝ) (a b : Fin n → ℝ) : Prop :=
  IntegrableOn f (closedRectangle a b) volume

structure RectanglePartition (n : ℕ) (a b : Fin n → ℝ) where
  pieces : Finset ℕ
  subrectangle : ℕ → Set (Fin n → ℝ)
  volume : ℕ → ℝ

theorem riemannIntegrableOnRectangle_iff_forall_exists_partition
    {n : ℕ} (f : (Fin n → ℝ) → ℝ) (a b : Fin n → ℝ) :
    RiemannIntegrableOnRectangle f a b ↔
      ∀ ε : ℝ, ε > 0 →
        ∃ P : RectanglePartition n a b,
          let M : ℕ → ℝ := fun k => sSup (f '' P.subrectangle k)
          let m : ℕ → ℝ := fun k => sInf (f '' P.subrectangle k)
          (∑ k in P.pieces, (M k - m k) * P.volume k) < ε := by
  sorry