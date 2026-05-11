import Mathlib

open Filter

def nearestIntegerDist (x : ℝ) : ℝ :=
  ⨅ n : ℤ, |x - (n : ℝ)|

def BadlyApproximable (α : ℝ) : Prop :=
  ∃ C : ℝ,
    0 < C ∧
      ∀ p : ℤ, ∀ q : ℕ, 0 < q →
        |α - (p : ℝ) / (q : ℝ)| ≥ C / (q : ℝ)^2

def Bad : Set ℝ :=
  {α : ℝ | BadlyApproximable α}

def LiminfAtTopPositive (u : ℕ → ℝ) : Prop :=
  ∃ ε : ℝ, 0 < ε ∧ ∀ᶠ q in Filter.atTop, ε ≤ u q

theorem badlyApproximable_iff_liminf_pos (α : ℝ) :
    α ∈ Bad ↔
      LiminfAtTopPositive (fun q : ℕ => (q : ℝ) * nearestIntegerDist ((q : ℝ) * α)) := by
  sorry