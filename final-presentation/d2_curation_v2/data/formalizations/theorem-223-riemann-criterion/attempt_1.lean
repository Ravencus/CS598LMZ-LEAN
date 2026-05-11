import Mathlib

open Set MeasureTheory

structure DarbouxPartition (a b : ℝ) where
  n : ℕ
  points : ℕ → ℝ
  monotone_points : Monotone points
  left_eq : points 0 = a
  right_eq : points n = b
  mesh : ℝ

def intervalOscillation (f : ℝ → ℝ) (u v : ℝ) : ℝ :=
  sSup (f '' Set.Icc u v) - sInf (f '' Set.Icc u v)

theorem intervalIntegrable_iff_forall_exists_mesh_partition_oscillation_sum_lt
    (f : ℝ → ℝ) (a b : ℝ)
    (hbounded : ∃ C > 0, ∀ x ∈ Set.Icc a b, |f x| ≤ C) :
    IntervalIntegrable f volume a b ↔
      ∀ ε > 0, ∃ δ : ℝ, δ > 0 ∧
        ∀ P : DarbouxPartition a b, P.mesh < δ →
          (∑ i in Finset.Icc 1 P.n,
            intervalOscillation f (P.points (i - 1)) (P.points i) *
              (P.points i - P.points (i - 1))) < ε := by
  sorry