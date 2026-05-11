import Mathlib

theorem continuous_graph_has_volume_zero
    (f : ℝ → ℝ) (hf : Continuous f) :
    MeasureTheory.volume ({p : ℝ × ℝ | p.2 = f p.1} : Set (ℝ × ℝ)) = 0 := by
  sorry