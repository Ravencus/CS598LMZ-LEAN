import Mathlib

noncomputable def seqLimsup (u : ℕ → ℝ) : ℝ :=
  sSup {x : ℝ | ClusterPt x (Filter.map u Filter.atTop)}

noncomputable def seqLiminf (u : ℕ → ℝ) : ℝ :=
  sInf {x : ℝ | ClusterPt x (Filter.map u Filter.atTop)}

theorem sin_nat_limsup_liminf :
    seqLimsup (fun n : ℕ => Real.sin n) = 1 ∧
      seqLiminf (fun n : ℕ => Real.sin n) = -1 := by
  sorry