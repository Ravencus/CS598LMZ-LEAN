import Mathlib

theorem sin_nat_dense_in_Icc :
    Set.Icc (-1 : ℝ) 1 ⊆ closure (Set.range (fun n : ℕ => Real.sin (n : ℝ))) := by
  sorry