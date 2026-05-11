import Mathlib

theorem hermite_floor_sum (x : ℝ) (n : ℕ) :
    Finset.sum (Finset.range n) (fun k => Int.floor (x + (k : ℝ) / (n : ℝ))) = Int.floor ((n : ℝ) * x) := by
  by_cases hn : n = 0
  · simp [hn]
  · have hterm : ∀ k ∈ Finset.range n,
        Int.floor (x + (k : ℝ) / (n : ℝ)) =
          (Int.floor ((n : ℝ) * x) + (k : ℤ)) / (n : ℤ) := by
      intro k hk
      have hnR : (n : ℝ) ≠ 0 := by exact_mod_cast hn
      have hcalc : x + (k : ℝ) / (n : ℝ) =
          (((n : ℝ) * x + (k : ℝ)) / (n : ℝ)) := by
        field_simp [hnR]
      rw [hcalc]
      rw [Int.floor_div_natCast]
      rw [Int.floor_add_natCast]
    rw [Finset.sum_congr rfl hterm]
    have hpure :
        (∑ k ∈ Finset.range n,
            (Int.floor ((n : ℝ) * x) + (k : ℤ)) / (n : ℤ)) =
          Int.floor ((n : ℝ) * x) := by
      sorry
    exact hpure