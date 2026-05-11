import Mathlib

theorem doubleSeries_converges :
    Summable (fun p : ℕ × ℕ =>
      ((-1 : ℝ) ^ Nat.sqrt (p.1 + 1)) /
        (((p.1 + 1 : ℝ) ^ (2 : ℕ)) + ((p.2 + 1 : ℝ) ^ (2 : ℕ)))) := by
  sorry