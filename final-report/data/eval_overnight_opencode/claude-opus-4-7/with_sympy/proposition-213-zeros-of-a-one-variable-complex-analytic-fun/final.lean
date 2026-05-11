import Mathlib

theorem isolated_zero_of_nonzero_holomorphic
    (U : Set ℂ) (f : ℂ → ℂ) (z0 : ℂ)
    (hU_open : IsOpen U)
    (hU_nonempty : U.Nonempty)
    (hU_connected : IsPreconnected U)
    (hf_holo : DifferentiableOn ℂ f U)
    (hf_nonzero : ¬ ∀ z ∈ U, f z = 0)
    (hz0U : z0 ∈ U)
    (hz0_zero : f z0 = 0) :
    ∃ r > 0, ∀ z, z ∈ U → ‖z - z0‖ < r → f z = 0 → z = z0 := by
  have hAn : AnalyticOnNhd ℂ f U := hf_holo.analyticOnNhd hU_open
  have hAt : AnalyticAt ℂ f z0 := hAn z0 hz0U
  rcases hAt.eventually_eq_zero_or_eventually_ne_zero with hzero | hnz
  · exfalso
    apply hf_nonzero
    exact hAn.eqOn_zero_of_preconnected_of_eventuallyEq_zero hU_connected hz0U hzero
  · have hnz' : ∀ᶠ z in nhds z0, z ≠ z0 → f z ≠ 0 := by
      rw [eventually_nhdsWithin_iff] at hnz
      exact hnz
    rw [Metric.eventually_nhds_iff] at hnz'
    obtain ⟨r, hr_pos, hball⟩ := hnz'
    refine ⟨r, hr_pos, ?_⟩
    intro z _hzU hzdist hfz
    by_contra hne
    have hd : dist z z0 < r := by rw [dist_eq_norm]; exact hzdist
    exact (hball hd hne) hfz