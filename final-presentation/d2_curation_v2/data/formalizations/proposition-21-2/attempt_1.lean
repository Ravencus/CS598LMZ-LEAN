import Mathlib

theorem min_with_p_series_divergence_convergence
    (a : ℕ → ℝ)
    (ha_nonneg : ∀ n : ℕ, 0 ≤ a n)
    (ha_nonincreasing : ∀ n : ℕ, a (n + 1) ≤ a n)
    (ha_diverges : ¬ Summable (fun n : ℕ => a (n + 1))) :
    (∀ p : ℝ, 0 < p → p ≤ 1 →
      ¬ Summable (fun n : ℕ => min (a (n + 1)) (1 / Real.rpow (n + 1 : ℝ) p))) ∧
    (∀ p : ℝ, 1 < p →
      Summable (fun n : ℕ => min (a (n + 1)) (1 / Real.rpow (n + 1 : ℝ) p))) := by
  sorry