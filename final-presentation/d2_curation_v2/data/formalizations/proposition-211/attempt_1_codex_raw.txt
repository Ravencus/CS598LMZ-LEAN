import Mathlib

noncomputable def seqLimsup (u : ℕ → ℝ) : ℝ :=
  ⨅ N : ℕ, sSup (u '' Set.Ici N)

noncomputable def seqLiminf (u : ℕ → ℝ) : ℝ :=
  ⨆ N : ℕ, sInf (u '' Set.Ici N)

theorem limsup_liminf_mul_of_nonneg_bounded
    (x y : ℕ → ℝ)
    (hx_nonneg : ∀ n : ℕ, 0 ≤ x n)
    (hy_nonneg : ∀ n : ℕ, 0 ≤ y n)
    (hx_bdd : ∃ Cx : ℝ, ∀ n : ℕ, x n ≤ Cx)
    (hy_bdd : ∃ Cy : ℝ, ∀ n : ℕ, y n ≤ Cy) :
    seqLimsup x * seqLimsup y ≥ seqLimsup (fun n : ℕ => x n * y n) ∧
      seqLimsup (fun n : ℕ => x n * y n) ≥ seqLiminf (fun n : ℕ => x n * y n) ∧
        seqLiminf (fun n : ℕ => x n * y n) ≥ seqLiminf x * seqLiminf y := by
  sorry