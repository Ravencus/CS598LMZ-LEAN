import Mathlib

def IrrationalityMeasureGreaterThanTwoSet : Set ℝ :=
  { x : ℝ |
      ∃ μ : ℝ,
        2 < μ ∧
          ∀ N : ℕ,
            ∃ q : ℕ,
              N ≤ q ∧
                0 < q ∧
                  ∃ p : ℤ,
                    |x - (p : ℝ) / (q : ℝ)| < 1 / Real.rpow (q : ℝ) μ }

theorem irrationalityMeasureGreaterThanTwoSet_volume_zero :
    MeasureTheory.volume IrrationalityMeasureGreaterThanTwoSet = 0 := by
  sorry