import Mathlib

theorem improperIntegralSeriesTest
    (M : ℕ) (f : ℝ → ℝ)
    (hmono : AntitoneOn f (Set.Ici (M : ℝ)))
    (hlim : Filter.Tendsto f Filter.atTop (nhds 0)) :
    (∃ l : ℝ, Filter.Tendsto (fun b : ℝ => ∫ t in Set.Icc (M : ℝ) b, f t) Filter.atTop (nhds l)) ↔
      Summable (fun n : ℕ => f (n + M)) := by
  sorry