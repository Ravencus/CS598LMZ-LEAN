import Mathlib

def UniformlyDistributedModOne (x : ℕ → ℝ) : Prop :=
  True

theorem uniformlyDistributedModOne_limsup_nat_mul_abs_difference_eq_top
    (x : ℕ → ℝ) (h_ud : UniformlyDistributedModOne x) :
    Filter.Tendsto
      (fun N : ℕ =>
        sSup ((fun n : ℕ => (n : ℝ) * |x (n + 1) - x n|) '' Set.Ici N))
      Filter.atTop
      Filter.atTop := by
  sorry