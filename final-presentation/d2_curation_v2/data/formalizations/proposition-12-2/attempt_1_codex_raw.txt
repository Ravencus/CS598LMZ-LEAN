import Mathlib

def IsIrrationalityMeasure (μ x : ℝ) : Prop :=
  ∀ ε : ℝ, 0 < ε →
    ∃ C : ℝ, 0 < C ∧
      ∀ p : ℤ, ∀ q : ℕ, 0 < q →
        C / (q : ℝ) ^ (μ + ε) ≤ |x - (p : ℝ) / (q : ℝ)|

noncomputable def irrationalityMeasure (x : ℝ) : ℝ :=
  sInf {μ : ℝ | IsIrrationalityMeasure μ x}

theorem irrationalityMeasure_ge_two_of_irrational {x : ℝ} (hx : Irrational x) :
    2 ≤ irrationalityMeasure x := by
  sorry