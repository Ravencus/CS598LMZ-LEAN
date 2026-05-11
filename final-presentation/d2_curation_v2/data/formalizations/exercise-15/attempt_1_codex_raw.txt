import Mathlib

theorem sqrt_abs_div_rpow_summable_of_summable_abs
    (a : ℕ → ℝ) {p : ℝ}
    (habs : Summable (fun n : ℕ => |a (n + 1)|))
    (hp : (1 : ℝ) / 2 < p) :
    Summable (fun n : ℕ => Real.sqrt (|a (n + 1)|) / Real.rpow (n + 1 : ℝ) p) := by
  sorry