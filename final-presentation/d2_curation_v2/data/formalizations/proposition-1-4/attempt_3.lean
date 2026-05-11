import Mathlib

open scoped BigOperators

def UniformlyDistributedModOne (u : ℕ → ℝ) : Prop := True

theorem uniformlyDistributedModOne_add_of_small_perturbation
    {x y : ℕ → ℝ}
    (hx : UniformlyDistributedModOne x)
    (hy : Asymptotics.IsLittleO Filter.atTop
      (fun N : ℕ => Finset.sum (Finset.range (N + 1)) (fun n : ℕ => |y n|))
      (fun N : ℕ => (N : ℝ))) :
    UniformlyDistributedModOne (fun n : ℕ => x n + y n) := by
  sorry