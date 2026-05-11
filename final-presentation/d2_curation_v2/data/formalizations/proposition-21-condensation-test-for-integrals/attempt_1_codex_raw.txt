import Mathlib

theorem cauchyCondensationIntegral_Ici
    (f : ℝ → ℝ)
    (h_loc : ∀ a b : ℝ, 1 ≤ a → a ≤ b → IntervalIntegrable f volume a b)
    (h_nonneg : ∀ x : ℝ, 1 ≤ x → 0 ≤ f x)
    (h_noninc : ∀ ⦃x y : ℝ⦄, 1 ≤ x → x ≤ y → f y ≤ f x) :
    IntegrableOn f (Set.Ici (1 : ℝ)) ↔
      Summable (fun n : ℕ => ((2 : ℝ) ^ (n + 1)) * f ((2 : ℝ) ^ (n + 1))) := by
  sorry

theorem cauchyCondensationIntegral_Ioc
    (f : ℝ → ℝ)
    (h_loc : ∀ a b : ℝ, 0 < a → a ≤ b → b ≤ 1 → IntervalIntegrable f volume a b)
    (h_nonneg : ∀ x : ℝ, 0 < x → x ≤ 1 → 0 ≤ f x)
    (h_noninc : ∀ ⦃x y : ℝ⦄, 0 < x → x ≤ y → y ≤ 1 → f y ≤ f x) :
    IntegrableOn f (Set.Ioc (0 : ℝ) 1) ↔
      Summable (fun n : ℕ => (((2 : ℝ) ^ (n + 1))⁻¹) * f (((2 : ℝ) ^ (n + 1))⁻¹)) := by
  sorry