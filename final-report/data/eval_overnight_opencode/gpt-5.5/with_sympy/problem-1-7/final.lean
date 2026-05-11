import Mathlib

open Filter
open scoped BigOperators Topology

example : Filter.Tendsto (fun n : ℕ => ((n : ℝ) + 1) / (2 * (n : ℝ))) Filter.atTop (nhds ((1:ℝ)/2)) := by
  have h : Filter.Tendsto (fun n : ℕ => (1 : ℝ) / 2 + (1 / 2) / (n : ℝ)) Filter.atTop (nhds ((1:ℝ)/2 + 0)) := by
    exact tendsto_const_nhds.add (tendsto_const_div_atTop_nhds_zero_nat ((1:ℝ)/2))
  have heq : (fun n : ℕ => ((n : ℝ) + 1) / (2 * (n : ℝ))) =ᶠ[Filter.atTop]
      (fun n : ℕ => (1 : ℝ) / 2 + (1 / 2) / (n : ℝ)) := by
    filter_upwards [eventually_ne_atTop 0] with n hn
    field_simp [Nat.cast_ne_zero.mpr hn, two_ne_zero]
  convert h.congr' heq.symm using 1
  ring
