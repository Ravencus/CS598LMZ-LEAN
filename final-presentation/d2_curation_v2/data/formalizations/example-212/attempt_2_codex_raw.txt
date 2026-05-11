import Mathlib

open Filter

def xSeq : ℕ → ℤ := fun _ => -1

def ySeq : ℕ → ℤ := fun n => (-1 : ℤ) ^ n

noncomputable def seqLimsup (u : ℕ → ℤ) : ℤ :=
  sInf {a : ℤ | ∀ᶠ n in Filter.atTop, u n ≤ a}

noncomputable def seqLiminf (u : ℕ → ℤ) : ℤ :=
  sSup {a : ℤ | ∀ᶠ n in Filter.atTop, a ≤ u n}

theorem proposition2111_nonnegativity_counterexample :
    (∀ n : ℕ, xSeq n * ySeq n = (-1 : ℤ) ^ (n + 1)) ∧
    seqLimsup (fun n => xSeq n * ySeq n) = 1 ∧
    seqLiminf (fun n => xSeq n * ySeq n) = -1 ∧
    seqLimsup xSeq * seqLimsup ySeq = -1 ∧
    seqLiminf xSeq * seqLiminf ySeq = 1 ∧
    ¬ (seqLimsup (fun n => xSeq n * ySeq n) ≤ seqLimsup xSeq * seqLimsup ySeq) ∧
    ¬ (seqLiminf xSeq * seqLiminf ySeq ≤ seqLiminf (fun n => xSeq n * ySeq n)) := by
  sorry