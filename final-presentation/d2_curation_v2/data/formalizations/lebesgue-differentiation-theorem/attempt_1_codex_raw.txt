import Mathlib

noncomputable section

open MeasureTheory Filter Topology

abbrev E (m : ℕ) := EuclideanSpace ℝ (Fin m)

def LocallyIntegrableOnEuclidean {m : ℕ} (f : E m → ℝ) : Prop :=
  ∀ K : Set (E m), IsCompact K → IntegrableOn f K volume

def IsLebesguePoint {m : ℕ} (f : E m → ℝ) (x : E m) : Prop :=
  Filter.Tendsto
    (fun r : ℝ =>
      (∫ y in Metric.closedBall x r, f y ∂volume) /
        (volume (Metric.closedBall x r)).toReal)
    (𝓝[>] (0 : ℝ))
    (𝓝 (f x))

theorem lebesgue_differentiation_theorem_ae
    {m : ℕ} {f : E m → ℝ}
    (hf : LocallyIntegrableOnEuclidean f) :
    ∀ᵐ x ∂(volume : Measure (E m)), IsLebesguePoint f x := by
  sorry