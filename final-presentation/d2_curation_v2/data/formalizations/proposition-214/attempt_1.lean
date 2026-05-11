import Mathlib

open scoped ENNReal

noncomputable def seqLimsup (u : ℕ → ℝ≥0∞) : ℝ≥0∞ :=
  ⨅ N : ℕ, sSup (Set.range fun n : ℕ => u (n + N))

noncomputable def seqLiminf (u : ℕ → ℝ≥0∞) : ℝ≥0∞ :=
  ⨆ N : ℕ, sInf (Set.range fun n : ℕ => u (n + N))

theorem reciprocal_seqLimsup_seqLiminf
    (x : ℕ → ℝ) (hx : ∀ n : ℕ, 0 < x n) :
    seqLimsup (fun n : ℕ => (ENNReal.ofReal (x n))⁻¹) =
      (seqLiminf (fun n : ℕ => ENNReal.ofReal (x n)))⁻¹
    ∧
    seqLiminf (fun n : ℕ => (ENNReal.ofReal (x n))⁻¹) =
      (seqLimsup (fun n : ℕ => ENNReal.ofReal (x n)))⁻¹ := by
  sorry