import Mathlib

open MeasureTheory Filter Topology Complex

noncomputable section

theorem riemannLebesgue_fourierCoefficients_tendsto_zero
    {f : ℝ → ℂ}
    (hf : IntervalIntegrable f volume (-Real.pi) Real.pi) :
    Tendsto
      (fun n : ℤ =>
        ‖((1 / (2 * Real.pi : ℂ)) *
          ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)))‖)
      (Filter.comap Int.natAbs Filter.atTop)
      (nhds 0) := by
  set g : ℝ → ℂ := (Set.Ioc (-Real.pi) Real.pi).indicator f with hg_def
  have hpi_pos : (0 : ℝ) < 2 * Real.pi := by positivity
  have hpi_ne : (Real.pi : ℂ) ≠ 0 := by exact_mod_cast Real.pi_ne_zero
  have hRL : Tendsto (fun w : ℝ => ∫ v : ℝ, Real.fourierChar (-(v * w)) • g v)
      (Filter.cocompact ℝ) (nhds (0 : ℂ)) :=
    Real.tendsto_integral_exp_smul_cocompact g
  have hmap : Tendsto (fun n : ℤ => ((n : ℝ) / (2 * Real.pi)))
      (Filter.comap Int.natAbs Filter.atTop) (Filter.cocompact ℝ) := by
    sorry
  have hcomp : Tendsto (fun n : ℤ => ∫ v : ℝ,
      Real.fourierChar (-(v * ((n : ℝ) / (2 * Real.pi)))) • g v)
      (Filter.comap Int.natAbs Filter.atTop) (nhds (0 : ℂ)) := hRL.comp hmap
  have hcomp2 : Tendsto (fun n : ℤ =>
      ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)))
      (Filter.comap Int.natAbs Filter.atTop) (nhds (0 : ℂ)) := by
    have key : ∀ n : ℤ, (∫ v : ℝ, Real.fourierChar (-(v * ((n : ℝ) / (2 * Real.pi)))) • g v) =
        ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)) := by
      intro n
      have step1 : ∀ v : ℝ,
          (Real.fourierChar (-(v * ((n : ℝ) / (2 * Real.pi)))) • g v : ℂ) =
          Complex.exp (-((n : ℂ) * (v : ℂ) * Complex.I)) * g v := by
        intro v
        rw [Circle.smul_def, Real.fourierChar_apply]
        have hexp : Complex.exp ((↑(2 * Real.pi * -(v * ((n : ℝ) / (2 * Real.pi)))) : ℂ) * Complex.I)
            = Complex.exp (-((n : ℂ) * (v : ℂ) * Complex.I)) := by
          congr 1
          push_cast
          field_simp
          ring
        rw [hexp]
        rfl
      simp_rw [step1]
      rw [hg_def]
      have hind : (fun v : ℝ => Complex.exp (-((n : ℂ) * (v : ℂ) * Complex.I)) *
              (Set.Ioc (-Real.pi) Real.pi).indicator f v) =
            (Set.Ioc (-Real.pi) Real.pi).indicator
              (fun v : ℝ => Complex.exp (-((n : ℂ) * (v : ℂ) * Complex.I)) * f v) := by
        funext v
        by_cases h : v ∈ Set.Ioc (-Real.pi) Real.pi
        · rw [Set.indicator_of_mem h, Set.indicator_of_mem h]
        · rw [Set.indicator_of_notMem h, Set.indicator_of_notMem h, mul_zero]
      rw [hind]
      rw [MeasureTheory.integral_indicator measurableSet_Ioc]
      rw [intervalIntegral.integral_of_le (by linarith [Real.pi_pos])]
      apply MeasureTheory.setIntegral_congr_fun measurableSet_Ioc
      intro v _
      ring
    simp_rw [key] at hcomp
    exact hcomp
  have hcomp3 : Tendsto (fun n : ℤ => ((1 / (2 * Real.pi : ℂ)) *
      ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I))))
      (Filter.comap Int.natAbs Filter.atTop) (nhds (0 : ℂ)) := by
    have := hcomp2.const_mul (1 / (2 * Real.pi : ℂ))
    simpa using this
  have := hcomp3.norm
  simpa using this