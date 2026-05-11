import Mathlib
open scoped Topology

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
  have hA : AnalyticOnNhd ℂ f U := hf_holo.analyticOnNhd hU_open
  have hz0A : AnalyticAt ℂ f z0 := hA z0 hz0U
  have hne : ∀ᶠ z in 𝓝[≠] z0, f z ≠ 0 := by
    rcases hz0A.eventually_eq_zero_or_eventually_ne_zero with hzero | hne
    · exfalso
      have hfw := hz0A.frequently_zero_iff_eventually_zero.mpr hzero
      have hEq : EqOn f 0 U :=
        hA.eqOn_zero_of_preconnected_of_frequently_eq_zero hU_connected hz0U hfw
      exact hf_nonzero (fun z hz => hEq hz)
    · exact hne
  have hne' : ∀ᶠ z in 𝓝 z0, z ≠ z0 → f z ≠ 0 := by
    simpa [eventually_nhdsWithin_iff] using hne
  rcases Metric.eventually_nhds_iff_ball.mp hne' with ⟨r, hr, hball⟩
  refine ⟨r, hr, ?_⟩
  intro z hzU hzlt hz0
  by_contra hneq
  have hznonzero : f z ≠ 0 :=
    hball z (by simpa [Metric.mem_ball, dist_eq_norm] using hzlt) hneq
  exact hznonzero hz0