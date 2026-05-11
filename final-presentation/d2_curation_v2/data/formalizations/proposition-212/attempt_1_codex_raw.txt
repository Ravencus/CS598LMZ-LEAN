import Mathlib

theorem log_nat_fractional_parts_dense :
    Dense
      (Set.range fun n : ℕ =>
        (⟨Real.fract (Real.log (n + 1)),
          by
            constructor
            · exact Real.fract_nonneg (Real.log (n + 1))
            · exact le_of_lt (Real.fract_lt_one (Real.log (n + 1)))⟩ :
          Set.Icc (0 : ℝ) 1)) := by
  sorry