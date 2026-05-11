import Mathlib

open Set

def alternatingSeq (n : ℕ) : ℝ :=
  if Even n then 2 else (1 / 2 : ℝ)

def seqLimsup (u : ℕ → ℝ) : ℝ :=
  sInf (Set.range fun N : ℕ => sSup (u '' {n : ℕ | N ≤ n}))

def seqLiminf (u : ℕ → ℝ) : ℝ :=
  sSup (Set.range fun N : ℕ => sInf (u '' {n : ℕ | N ≤ n}))

theorem alternatingSeq_limsup_liminf :
    seqLimsup alternatingSeq = 2 ∧
    seqLimsup (fun n => 1 / alternatingSeq n) = 2 ∧
    seqLimsup alternatingSeq * seqLimsup (fun n => 1 / alternatingSeq n) = 4 ∧
    1 < seqLimsup alternatingSeq * seqLimsup (fun n => 1 / alternatingSeq n) ∧
    seqLiminf alternatingSeq * seqLiminf (fun n => 1 / alternatingSeq n) = (1 / 4 : ℝ) ∧
    seqLiminf alternatingSeq * seqLiminf (fun n => 1 / alternatingSeq n) < 1 := by
  sorry