import Mathlib

theorem cauchy_condensation_integral_iff
    (f : ℝ → ℝ)
    (h_int : ∀ M : ℝ, 1 ≤ M → IntervalIntegrable f volume 1 M)
    (h_nonneg : ∀ x : ℝ, 1 ≤ x → 0 ≤ f x)
    (h_antitone : ∀ ⦃x y : ℝ⦄, 1 ≤ x → x ≤ y → f y ≤ f x) :
    (∃ L : ℝ, Filter.Tendsto (fun b : ℝ => ∫ x in 1..b, f x) Filter.atTop (nhds L)) ↔
      Summable (fun n : ℕ => (2 : ℝ) ^ (n + 1) * f ((2 : ℝ) ^ (n + 1))) := by
  sorry