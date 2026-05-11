import Mathlib

open MeasureTheory

noncomputable def fubiniCounterexample (x y : ℝ) : ℝ :=
  if x = 0 ∧ y = 0 then
    0
  else
    (x ^ 2 - y ^ 2) / (x ^ 2 + y ^ 2) ^ 2

noncomputable def unitSquareMeasure : Measure (ℝ × ℝ) :=
  volume.restrict ((Set.Icc (0 : ℝ) 1) ×ˢ (Set.Icc (0 : ℝ) 1))

theorem fubini_counterexample_main :
    Measurable (fun p : ℝ × ℝ => |fubiniCounterexample p.1 p.2|) ∧
      ((∫⁻ p : ℝ × ℝ,
          ENNReal.ofReal |fubiniCounterexample p.1 p.2| ∂unitSquareMeasure) = (∞ : ℝ≥0∞)) ∧
      (¬ Integrable
          (fun p : ℝ × ℝ => fubiniCounterexample p.1 p.2)
          unitSquareMeasure) ∧
      ((∫ x in (0 : ℝ)..1, ∫ y in (0 : ℝ)..1, fubiniCounterexample x y) = Real.pi / 4) ∧
      ((∫ y in (0 : ℝ)..1, ∫ x in (0 : ℝ)..1, fubiniCounterexample x y) = -(Real.pi / 4)) := by
  sorry