import Mathlib

open MeasureTheory

theorem pushforward_integral_comp
    {X Y : Type*} [MeasurableSpace X] [MeasurableSpace Y]
    (μ : Measure X) (T : X → Y) (hT : Measurable T) (g : Y → ℝ)
    (hg : Integrable g (Measure.map T μ)) :
    MeasureTheory.integral (Measure.map T μ) g =
      MeasureTheory.integral μ (fun x => g (T x)) := by
  sorry