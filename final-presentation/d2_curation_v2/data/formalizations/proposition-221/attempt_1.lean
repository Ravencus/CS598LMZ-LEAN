import Mathlib

noncomputable def seqLiminf (u : ℕ → ℝ) : ℝ :=
  sSup (Set.range fun n : ℕ => sInf (Set.range fun m : ℕ => u (n + m)))

noncomputable def seqLimsup (u : ℕ → ℝ) : ℝ :=
  sInf (Set.range fun n : ℕ => sSup (Set.range fun m : ℕ => u (n + m)))

theorem liminf_limsup_add_inequalities (x y : ℕ → ℝ) :
    seqLiminf x + seqLiminf y ≤ seqLiminf (fun n => x n + y n) ∧
    seqLiminf (fun n => x n + y n) ≤ seqLiminf x + seqLimsup y ∧
    seqLiminf x + seqLimsup y ≤ seqLimsup (fun n => x n + y n) ∧
    seqLimsup (fun n => x n + y n) ≤ seqLimsup x + seqLimsup y := by
  sorry