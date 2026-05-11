import Mathlib

open MeasureTheory Topology Filter

noncomputable section

def translate {n : ℕ} (a : EuclideanSpace ℝ (Fin n)) (f : EuclideanSpace ℝ (Fin n) → ℂ) :
    EuclideanSpace ℝ (Fin n) → ℂ :=
  fun x => f (x - a)

theorem l1_translation_continuous {n : ℕ} (f : EuclideanSpace ℝ (Fin n) → ℂ)
    (hf : Integrable f) (a : EuclideanSpace ℝ (Fin n)) :
    Filter.Tendsto
      (fun h : EuclideanSpace ℝ (Fin n) =>
        ∫ x, ‖translate (a + h) f x - translate a f x‖ ∂volume)
      (nhds (0 : EuclideanSpace ℝ (Fin n)))
      (nhds (0 : ℝ)) := by
  sorry