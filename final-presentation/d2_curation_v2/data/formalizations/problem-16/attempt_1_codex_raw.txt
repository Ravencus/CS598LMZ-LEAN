import Mathlib

theorem summable_of_summable_pos_rpow_one_sub_inv_log
    (a : ℕ → ℝ)
    (ha_pos : ∀ n : ℕ, 0 < a n)
    (ha_summable : Summable (fun n : ℕ => a (n + 1))) :
    Summable (fun n : ℕ => Real.rpow (a (n + 3)) (1 - 1 / Real.log (n + 3 : ℝ))) := by
  sorry