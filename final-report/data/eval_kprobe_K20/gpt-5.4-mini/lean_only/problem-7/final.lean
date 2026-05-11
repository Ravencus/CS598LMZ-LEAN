import Mathlib

example : Summable (fun n : ℕ => (1 : ℝ) / ((n + 1 : ℝ) ^ (3 / 2 : ℝ))) := by
  simpa [div_eq_mul_inv, one_div] using (summable_nat_rpow (by norm_num : (1 : ℝ) < 3 / 2))