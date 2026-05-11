import Mathlib

theorem alternating_series_convergent_of_antitone_tendsto_zero
    {a : ℕ → ℝ}
    (ha_pos : ∀ n, 0 < a n)
    (ha_antitone : Antitone a)
    (ha_lim : Filter.Tendsto a Filter.atTop (nhds 0)) :
    Summable (fun n => (-1 : ℝ) ^ n * a n) := by
  sorry