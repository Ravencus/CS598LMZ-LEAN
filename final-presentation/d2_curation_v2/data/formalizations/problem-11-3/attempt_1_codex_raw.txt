import Mathlib

theorem fractional_parts_nat_div_two_pi_dense_in_unitInterval :
    Set.Icc (0 : ℝ) 1 ⊆
      Set.closure (Set.range fun n : ℕ => Int.fract ((n : ℝ) / (2 * Real.pi))) := by
  sorry