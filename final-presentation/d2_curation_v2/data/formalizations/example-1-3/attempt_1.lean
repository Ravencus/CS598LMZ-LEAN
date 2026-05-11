import Mathlib

noncomputable section

open MeasureTheory

def Y₁ : Bool → ℕ
  | false => 0
  | true => 1

theorem bernoulli_pushforward_singletons
    (p : ℝ≥0∞) (hp : p ≤ 1) (P0 : Measure Bool)
    (hfalse : P0 {false} = 1 - p) (htrue : P0 {true} = p) :
    (Measure.map Y₁ P0) {0} = 1 - p ∧ (Measure.map Y₁ P0) {1} = p := by
  sorry