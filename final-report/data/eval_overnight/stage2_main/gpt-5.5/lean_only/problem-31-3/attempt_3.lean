import Mathlib

theorem harmonic_log_series_diverges :
    ¬ Summable (fun n : ℕ => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2))) := by
  simpa [Nat.cast_add, Nat.cast_ofNat, add_comm, add_left_comm, add_assoc]
    using Real.not_summable_one_div_nat_succ_mul_log_succ_of_one_lt 1