import Mathlib

noncomputable def zetaReal (r : ℝ) : ℝ :=
  ∑' k : ℕ, Real.rpow ((k + 1 : ℕ) : ℝ) (-r)

theorem zeta_partial_sum_asymptotic
    (r : ℝ) (hr : 1 < r) :
    Asymptotics.IsBigO Filter.atTop
      (fun n : ℕ =>
        (∑ k ∈ Finset.Icc 1 n, Real.rpow (k : ℝ) (-r)) -
          (zetaReal r
            + (1 / (1 - r)) * Real.rpow (n : ℝ) (1 - r)
            + (1 / 2 : ℝ) * Real.rpow (n : ℝ) (-r)
            - (r / 12 : ℝ) * Real.rpow (n : ℝ) (-r - 1)))
      (fun n : ℕ => Real.rpow (n : ℝ) (-r - 3)) := by
  sorry