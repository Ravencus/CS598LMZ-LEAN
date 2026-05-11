import Mathlib

open Filter Topology

def IsSeqLimsup (x : ℕ → ℝ) (b : ℝ) : Prop :=
  ∃ φ : ℕ → ℕ, StrictMono φ ∧ Filter.Tendsto (fun n : ℕ => x (φ n)) Filter.atTop (nhds b)

def IsSeqLiminf (x : ℕ → ℝ) (a : ℝ) : Prop :=
  ∃ φ : ℕ → ℕ, StrictMono φ ∧ Filter.Tendsto (fun n : ℕ => x (φ n)) Filter.atTop (nhds a)

def DenseInOpenInterval (x : ℕ → ℝ) (a b : ℝ) : Prop :=
  ∀ y : ℝ, y ∈ Set.Ioo a b → ∀ ε : ℝ, ε > 0 → ∃ n : ℕ, |x n - y| < ε

theorem dense_in_open_interval_of_bounded_limsup_liminf_and_vanishing_steps
    (x : ℕ → ℝ) (a b : ℝ)
    (hbounded : ∃ M : ℝ, ∀ n : ℕ, |x n| ≤ M)
    (hlimsup : IsSeqLimsup x b)
    (hliminf : IsSeqLiminf x a)
    (hne : a ≠ b)
    (hstep : Filter.Tendsto (fun n : ℕ => x (n + 1) - x n) Filter.atTop (nhds (0 : ℝ))) :
    DenseInOpenInterval x a b := by
  sorry