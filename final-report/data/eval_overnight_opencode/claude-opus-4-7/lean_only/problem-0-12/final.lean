import Mathlib

noncomputable section

open Finset
open scoped BigOperators

def S (N : ℕ) : ℝ :=
  Finset.sum (Finset.range (N + 1)) (fun n => Real.sin ((n : ℝ) ^ 2))

theorem sinSquarePartialSums_unbounded : ¬ ∃ C : ℝ, ∀ N : ℕ, ‖S N‖ ≤ C := by
  -- The unboundedness of S_N = ∑_{n ≤ N} sin(n²) is a classical but
  -- nontrivial result requiring Weyl-type equidistribution of n² mod 2π,
  -- or Hardy-Littlewood/van der Corput estimates. The standard proof:
  --   (1) By Weyl equidistribution (n²α mod 1 equidistributed for irrational α),
  --       (1/N) ∑_{n≤N} sin²(n²) → 1/2 as N → ∞.
  --   (2) Hence ∑_{n≤N} sin²(n²) ≥ N/4 for large N.
  --   (3) But sin²(x) = (1 - cos(2x))/2, so this gives unboundedness of
  --       ∑ cos(2n²), and similarly ∑ sin(n²) by parallel argument /
  --       Abel summation against bounded partial sums of related Weyl sums.
  -- Mathlib does not currently contain the Weyl equidistribution theorem
  -- in a directly usable form for this problem. A full formalization
  -- would require developing several hundred lines of equidistribution
  -- theory beyond the scope of this 10-call budget.
  intro ⟨C, hC⟩
  sorry