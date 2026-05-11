import Mathlib

theorem nonnegative_sq_limsup_liminf
    (x : ℕ → ℝ) (hx : ∀ n : ℕ, 0 ≤ x n) :
    sInf (Set.range (fun N : ℕ => sSup (Set.range (fun n : ℕ => (x (n + N)) ^ 2)))) =
      (sInf (Set.range (fun N : ℕ => sSup (Set.range (fun n : ℕ => x (n + N)))))) ^ 2
    ∧
    sSup (Set.range (fun N : ℕ => sInf (Set.range (fun n : ℕ => (x (n + N)) ^ 2)))) =
      (sSup (Set.range (fun N : ℕ => sInf (Set.range (fun n : ℕ => x (n + N)))))) ^ 2 := by
  sorry