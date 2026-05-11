import Mathlib

open Filter

def A (a : ℝ) (N : ℕ) : ℝ :=
  ∏ n in Finset.Icc 1 N, (n : ℝ) / ((n : ℝ) + a)

theorem tendsto_A_zero_of_pos (a : ℝ) (ha : 0 < a) :
    Tendsto (fun N : ℕ => A a N) atTop (𝓝 0) := by
  sorry