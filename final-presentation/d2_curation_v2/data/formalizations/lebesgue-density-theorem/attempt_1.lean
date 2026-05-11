import Mathlib

open MeasureTheory

noncomputable def densityFunction {n : ℕ} (A : Set (Fin n → ℝ)) : (Fin n → ℝ) → ℝ :=
  Set.indicator A (fun _ => (1 : ℝ))

def IsDensityPoint {n : ℕ} (A : Set (Fin n → ℝ)) (x : Fin n → ℝ) : Prop :=
  densityFunction A x = 1

theorem ae_density_eq_indicator_of_measurable
    {n : ℕ} (A : Set (Fin n → ℝ)) (hA : MeasurableSet A) :
    ∀ᵐ x ∂(volume : Measure (Fin n → ℝ)),
      densityFunction A x = Set.indicator A (fun _ => (1 : ℝ)) x := by
  sorry