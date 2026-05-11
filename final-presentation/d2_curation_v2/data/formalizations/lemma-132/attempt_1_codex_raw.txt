import Mathlib

noncomputable section

def normalizedBySqrt (u : ℕ → ℝ) (n : ℕ) : ℝ :=
  u n / Real.sqrt (n : ℝ)

def tailInf (u : ℕ → ℝ) (n : ℕ) : ℝ :=
  sInf (Set.range fun m : ℕ => normalizedBySqrt u (n + m))

def tailSup (u : ℕ → ℝ) (n : ℕ) : ℝ :=
  sSup (Set.range fun m : ℕ => normalizedBySqrt u (n + m))

def seqLiminf (u : ℕ → ℝ) : ℝ :=
  sSup (Set.range fun n : ℕ => tailInf u n)

def seqLimsup (u : ℕ → ℝ) : ℝ :=
  sInf (Set.range fun n : ℕ => tailSup u n)

theorem sqrtNormalized_liminf_limsup_pos_le_finite
    (aₙ : ℕ → ℝ) :
    let a := seqLiminf aₙ
    let b := seqLimsup aₙ
    0 < a ∧ a ≤ b ∧ ∃ M : ℝ, b < M := by
  sorry