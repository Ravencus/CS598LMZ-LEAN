import Mathlib

open Filter Topology

def A (a : ℝ) (N : ℕ) : ℝ :=
  ∏ n ∈ Finset.Icc 1 N, (n : ℝ) / ((n : ℝ) + a)

theorem product_ratio_tendsTo_zero {a : ℝ} (ha : 0 < a) :
    Tendsto (fun N : ℕ => A a N) atTop (nhds 0) := by
  sorry