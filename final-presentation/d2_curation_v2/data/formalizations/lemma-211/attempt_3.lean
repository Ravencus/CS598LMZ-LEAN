import Mathlib

noncomputable def harmonicNumber (N : ℕ) : ℝ :=
  Finset.sum (Finset.Icc 1 N) (fun k => (k : ℝ)⁻¹)

theorem harmonicNumber_gt_log_add_one_half (N : ℕ) (hN : 0 < N) :
    harmonicNumber N > Real.log (N : ℝ) + (1 / 2 : ℝ) := by
  sorry