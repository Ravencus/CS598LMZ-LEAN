import Mathlib

theorem kummersTest
    (a ξ : ℕ → ℝ)
    (ha_pos : ∀ n, 0 < a n)
    (hξ_pos : ∀ n, 0 < ξ n)
    (ρ : ℝ)
    (hρ :
      Filter.Tendsto
        (fun n => ξ n * (a n / a (n + 1)) - ξ (n + 1))
        Filter.atTop
        (nhds ρ)) :
    ((0 < ρ) → Summable (fun n => a (n + 1))) ∧
    ((ρ < 0) → ¬ Summable (fun n => (ξ (n + 1))⁻¹) → ¬ Summable (fun n => a (n + 1))) := by
  sorry