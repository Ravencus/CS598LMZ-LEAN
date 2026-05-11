import Mathlib

theorem alternatingHarmonicSeries_converges :
    Summable (fun n : ℕ => ((-1 : ℝ) ^ (n + 1)) / (n + 1 : ℝ)) := by
  sorry