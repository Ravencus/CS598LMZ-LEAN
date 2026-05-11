import Mathlib

open Polynomial

example {α : ℝ} (h_alg : IsAlgebraic ℚ α) : True := by
  have h_int : IsIntegral ℚ α := h_alg.isIntegral
  let f := minpoly ℚ α
  have h_monic : f.Monic := minpoly.monic h_int
  have h_aeval : aeval α f = 0 := minpoly.aeval ℚ α
  have h_irred : Irreducible f := minpoly.irreducible h_int
  have h_ne_zero : f ≠ 0 := minpoly.ne_zero h_int
  let fℝ := f.map (algebraMap ℚ ℝ)
  have h_root : fℝ.eval α = 0 := by
    rw [Polynomial.eval_map]
    rw [← aeval_def]
    exact h_aeval
  have h_dvd : (X - C (α : ℝ)) ∣ fℝ :=
    dvd_iff_isRoot.mpr h_root
  trivial