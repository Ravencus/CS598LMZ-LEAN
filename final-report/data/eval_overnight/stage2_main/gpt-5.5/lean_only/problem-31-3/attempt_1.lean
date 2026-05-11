import Mathlib

theorem harmonic_log_series_diverges :
    ¬ Summable (fun n : ℕ => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2))) := by
  intro h
  have h0 : ¬ Summable (fun n : ℕ => 1 / ((n : ℝ) * Real.log (n : ℝ))) := by
    simpa [one_div] using Real.not_summable_one_div_nat_mul_log
  apply h0
  have hshift :
      Summable
        (fun n : ℕ =>
          1 / (((n + 2 : ℕ) : ℝ) * Real.log ((n + 2 : ℕ) : ℝ))) := by
    simpa [Nat.cast_add, Nat.cast_ofNat, add_comm, add_left_comm, add_assoc] using h
  exact (summable_nat_add_iff 2).1 hshift