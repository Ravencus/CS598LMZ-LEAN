import Mathlib

noncomputable def RaabeTerm (a : ℕ → ℝ) (n : ℕ) : ℝ :=
  (n : ℝ) * (a n / a (n + 1) - 1)

theorem raabe_test
    {a : ℕ → ℝ} (ha : ∀ n : ℕ, 0 < a n) {L : ℝ}
    (hlim : Filter.Tendsto (RaabeTerm a) Filter.atTop (𝓝 L)) :
    (1 < L → Summable a) ∧ (L < 1 → ¬ Summable a) := by
  sorry