import Mathlib

open Set

def seqLimsup (u : ℕ → ℝ) : ℝ :=
  sInf (Set.range fun n : ℕ => sSup (u '' Set.Ici n))

def seqLiminf (u : ℕ → ℝ) : ℝ :=
  sSup (Set.range fun n : ℕ => sInf (u '' Set.Ici n))

theorem nonnegative_bounded_sequences_limsup_liminf_mul
    (x y : ℕ → ℝ)
    (hx_nonneg : ∀ n, 0 ≤ x n)
    (hy_nonneg : ∀ n, 0 ≤ y n)
    (hx_bdd : ∃ M, ∀ n, x n ≤ M)
    (hy_bdd : ∃ M, ∀ n, y n ≤ M) :
    seqLimsup x * seqLimsup y ≥ seqLimsup (fun n => x n * y n) ∧
      seqLimsup (fun n => x n * y n) ≥ seqLiminf (fun n => x n * y n) ∧
      seqLiminf (fun n => x n * y n) ≥ seqLiminf x * seqLiminf y := by
  sorry