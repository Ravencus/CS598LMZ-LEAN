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
  classical
  have hf_an : AnalyticAt ℂ f z0 := hf_holo.analyticAt (hU_open.mem_nhds hz0U)
  rcases hf_an.eventually_eq_zero_or_eventually_ne_zero with hzero | hne
  · exfalso
    have hzero_an : AnalyticOnNhd ℂ (fun _ : ℂ => (0 : ℂ)) U := analyticOnNhd_const
    have hf_an_on : AnalyticOnNhd ℂ f U := hf_holo.analyticOnNhd hU_open
    have hEq : Set.EqOn f (fun _ : ℂ => (0 : ℂ)) U :=
      hf_an_on.eqOn_of_preconnected_of_eventuallyEq hzero_an hU_connected hz0U hzero
    exact hf_nonzero (by
      intro z hz
      simpa using hEq hz)
  · rw [Metric.eventually_nhds_iff] at hne
    rcases hne with ⟨r, hrpos, hr⟩
    refine ⟨r, hrpos, ?_⟩
    intro z hzU hzdist hzzero
    by_contra hzne
    have hzmem : z ∈ ({z0}ᶜ : Set ℂ) := by
      simpa [Set.mem_compl_iff, Set.mem_singleton_iff] using hzne
    have hdist : dist z z0 < r := by
      simpa [dist_eq_norm] using hzdist
    exact (hr z hdist hzmem) hzzero