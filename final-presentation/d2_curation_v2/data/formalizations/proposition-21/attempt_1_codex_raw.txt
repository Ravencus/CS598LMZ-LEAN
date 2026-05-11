import Mathlib

noncomputable def scaledSeq (aSeq : ℕ → ℝ) (β : ℝ) (n : ℕ) : ℝ :=
  aSeq n / Real.rpow (n : ℝ) β

noncomputable def seqLiminf (u : ℕ → ℝ) : ℝ :=
  sSup (Set.range fun N : ℕ => sInf (u '' {n : ℕ | N ≤ n}))

noncomputable def seqLimsup (u : ℕ → ℝ) : ℝ :=
  sInf (Set.range fun N : ℕ => sSup (u '' {n : ℕ | N ≤ n}))

theorem liminf_limsup_scaled_sequence_bounds
    (aSeq : ℕ → ℝ) (β a b : ℝ)
    (hβ : 0 < β)
    (ha : a = seqLiminf (scaledSeq aSeq β))
    (hb : b = seqLimsup (scaledSeq aSeq β)) :
    Real.sqrt ((β + 1) / β) ≤ a ∧ a ≤ b ∧ b ≤ Real.sqrt ((β + 1) / β) := by
  sorry