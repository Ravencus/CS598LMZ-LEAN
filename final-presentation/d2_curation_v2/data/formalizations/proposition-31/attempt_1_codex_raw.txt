import Mathlib

theorem asymptotic_sequence_limit
    {a f S : ℕ → ℝ} {α β : ℝ}
    (ha1 : 0 < a 1)
    (hβ : 0 < β)
    (hα : 0 < α)
    (hf_pos : ∀ n : ℕ, 0 < f n)
    (hS_pos : ∀ n : ℕ, 0 < S n)
    (hΔ : ∀ n : ℕ, a (n + 1) - a n = f n / S n)
    (hf_asymp :
      Filter.Tendsto
        (fun n : ℕ => f n / Real.rpow (n : ℝ) (2 * β))
        Filter.atTop
        (nhds α)) :
    Filter.Tendsto
      (fun n : ℕ => a n / Real.rpow (n : ℝ) β)
      Filter.atTop
      (nhds (Real.sqrt (α * (β + 1) / β))) := by
  sorry