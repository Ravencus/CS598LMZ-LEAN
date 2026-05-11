import Mathlib

open scoped Topology

noncomputable section

def S (N : ℕ) : ℝ :=
  Finset.sum (Finset.range (N + 1)) (fun n => (1 : ℝ) / (Nat.factorial n : ℝ))

def remainderTerm (n : ℕ) : ℝ :=
  (1 : ℝ) /
    (((n + 1 : ℕ) : ℝ) * ((n + 2 : ℕ) : ℝ) * (Nat.factorial (n + 2) : ℝ))

def T (N : ℕ) : ℝ :=
  3 - Finset.sum (Finset.range (N + 1)) remainderTerm

theorem exp_partial_sums_limit_series_identity_and_error_analysis :
    (∃ l : ℝ, Filter.Tendsto S Filter.atTop (Filter.nhds l)) ∧
      (∀ e : ℝ, Filter.Tendsto S Filter.atTop (Filter.nhds e) →
        e = 3 - ∑' n : ℕ, remainderTerm n) ∧
      (∀ e : ℝ, Filter.Tendsto S Filter.atTop (Filter.nhds e) →
        ∃ R : ℕ → ℝ,
          (∀ N : ℕ, e = T N + R N) ∧
          (∀ N : ℕ, |R N| ≤ (1 : ℝ) / (Nat.factorial (N + 3) : ℝ))) := by
  sorry