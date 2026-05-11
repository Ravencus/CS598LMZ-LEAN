import Mathlib

open MeasureTheory Filter Topology

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
  -- Strategy: Extend f by 0 to ℝ to get integrable g on all of ℝ.
  -- Then the interval integral equals ∫_ℝ g(x) e^{-inx} dx, which is
  -- (essentially) the Fourier transform of g at n. The classical
  -- Riemann-Lebesgue lemma (Real.zero_at_infty_fourier in Mathlib)
  -- gives this tends to 0 as |n| → ∞, since comap natAbs atTop on ℤ
  -- maps into cocompact ℝ via the inclusion ℤ ↪ ℝ.
  set g : ℝ → ℂ := (Set.Ioc (-Real.pi) Real.pi).indicator f with hg_def
  have hpi : (-Real.pi : ℝ) ≤ Real.pi := by linarith [Real.pi_pos]
  have hg_int : Integrable g volume := by
    rw [hg_def]
    exact (hf.1).integrable_indicator measurableSet_Ioc
  suffices h : Tendsto
      (fun n : ℤ => ((1 / (2 * Real.pi : ℂ)) *
          ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I))))
      (Filter.comap Int.natAbs Filter.atTop) (nhds 0) by
    simpa using h.norm
  have hconst : Tendsto (fun _ : ℤ => (1 / (2 * Real.pi : ℂ)))
      (Filter.comap Int.natAbs Filter.atTop) (nhds (1 / (2 * Real.pi : ℂ))) :=
    tendsto_const_nhds
  suffices h2 : Tendsto
      (fun n : ℤ => ∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)))
      (Filter.comap Int.natAbs Filter.atTop) (nhds 0) by
    have := hconst.mul h2
    simpa using this
  have heq : ∀ n : ℤ,
      (∫ x in -Real.pi..Real.pi, f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I))) =
      ∫ x, g x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)) := by
    intro n
    rw [intervalIntegral.integral_of_le hpi, hg_def,
        ← MeasureTheory.integral_indicator measurableSet_Ioc]
    refine integral_congr_ae ?_
    filter_upwards with x
    by_cases hx : x ∈ Set.Ioc (-Real.pi) Real.pi
    · simp [Set.indicator_of_mem hx]
    · simp [Set.indicator_of_notMem hx]
  rw [show (fun n : ℤ => ∫ x in -Real.pi..Real.pi,
      f x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I))) =
      (fun n : ℤ => ∫ x, g x * Complex.exp (-((n : ℂ) * (x : ℂ) * Complex.I)))
      from funext heq]
  have hRL : Tendsto (fun s : ℝ => ∫ x, g x * Complex.exp (-((s : ℂ) * (x : ℂ) * Complex.I)))
      (cocompact ℝ) (nhds 0) :=
    hg_int.tendsto_integral_mul_exp_atTop_nhds_zero.cocompact
  have hmap : Tendsto (fun n : ℤ => (n : ℝ))
      (Filter.comap Int.natAbs Filter.atTop) (cocompact ℝ) :=
    Int.tendsto_coe_cofinite.mono_left
      (Filter.comap_mono Filter.cofinite_eq_atBot_atTop.le)
  have := hRL.comp hmap
  convert this using 1
  funext n
  congr 1
  funext x
  push_cast
  ring_nf