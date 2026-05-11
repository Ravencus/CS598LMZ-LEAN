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
  have hAOn : AnalyticOnNhd ℂ f U := hf_holo.analyticOnNhd hU_open
  have hAAt : AnalyticAt ℂ f z0 := hAOn z0 hz0U
  rcases hAAt.eventually_eq_zero_or_eventually_ne_zero with hzero | hne
  · exfalso
    apply hf_nonzero
    intro z hz
    have hEq : Set.EqOn f 0 U :=
      hAOn.eqOn_zero_of_preconnected_of_eventuallyEq_zero hU_connected hz0U hzero
    simpa using hEq hz
  · have h_basis := (Metric.nhdsWithin_basis_ball (x := z0) (s := ({z0} : Set ℂ)ᶜ))
    rcases h_basis.eventually_iff.mp hne with ⟨r, hr_pos, hr⟩
    refine ⟨r, hr_pos, ?_⟩
    intro z hzU hz_dist hz_fzero
    by_contra hne_z
    have hz_mem : z ∈ Metric.ball z0 r ∩ ({z0} : Set ℂ)ᶜ := by
      refine ⟨?_, ?_⟩
      · simp [Metric.mem_ball, dist_eq_norm, hz_dist]
      · intro hmem
        apply hne_z
        simpa using hmem
    exact (hr hz_mem) hz_fzero