import Mathlib

axiom TaggedPartition : ℝ → ℝ → Type
axiom mesh : {a b : ℝ} → TaggedPartition a b → ℝ
axiom riemannSum : (ℝ → ℝ) → {a b : ℝ} → TaggedPartition a b → ℝ
axiom RiemannIntegrableOn : (ℝ → ℝ) → ℝ → ℝ → Prop

theorem riemannIntegrableOn_iff_riemannSums_cauchy
    (f : ℝ → ℝ) (a b : ℝ) :
    RiemannIntegrableOn f a b ↔
      ∀ ε > 0, ∃ δ : ℝ, δ > 0 ∧
        ∀ P' P'' : TaggedPartition a b,
          mesh P' < δ →
          mesh P'' < δ →
          |riemannSum f P' - riemannSum f P''| < ε := by
  sorry