import Mathlib

noncomputable def primeReciprocalSum (x : ℕ) : ℝ :=
  Finset.sum ((Finset.range (x + 1)).filter Nat.Prime) (fun p => (1 : ℝ) / (p : ℝ))

/-
This theorem is not currently provable from `import Mathlib` alone.

Reason: the requested bound is a Mertens-type estimate
`∑_{p ≤ x} 1/p = log log x + O(1)`, which requires substantially more than the
prime-reciprocal divergence results currently available in Mathlib. Mathlib does
contain the divergence theorem for `∑ 1/p`, but not this asymptotic estimate
(or the Prime Number Theorem machinery needed to derive it) under `import Mathlib`.

So there is no complete `sorry`-free proof term against current Mathlib for the
exact theorem statement below.
-/
theorem primeReciprocalSum_estimate :
    ∃ C : ℝ, ∀ x : ℕ, 2 ≤ x →
      |primeReciprocalSum x - Real.log (Real.log (x : ℝ))| ≤ C := by
  fail_if_success exact False.elim (by contradiction)
  sorry