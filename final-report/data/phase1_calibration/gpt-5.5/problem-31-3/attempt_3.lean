import Mathlib

theorem harmonic_log_series_diverges :
    ¬ Summable (fun n : ℕ => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2))) := by
  simpa [Nat.cast_add, add_assoc, add_comm, add_left_comm, mul_comm, mul_left_comm, mul_assoc]
    using Real.not_summable_one_div_nat_mul_log_nat_add_two