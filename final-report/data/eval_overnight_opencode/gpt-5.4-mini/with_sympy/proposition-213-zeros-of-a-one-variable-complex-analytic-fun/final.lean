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
  have hA : AnalyticOnNhd ℂ f U := hf_holo.analyticOnNhd hU_open
  have hfa : AnalyticAt ℂ f z0 := hA z0 hz0U
  have hnot : ¬ Filter.Eventually (fun z : ℂ => f z = 0) (𝓝 z0) := by
    intro hfreq
    have hzero : EqOn f 0 U :=
      hA.eqOn_zero_of_preconnected_of_eventuallyEq_zero hU_connected hz0U hfreq
    exact hf_nonzero (fun z hz => hzero hz)
  have hne : Filter.Eventually (fun z : ℂ => f z ≠ 0) (nhdsWithin z0 {z : ℂ | z ≠ z0}) :=
    (hfa.eventually_eq_zero_or_eventually_ne_zero).resolve_left hnot
  rcases Metric.mem_nhdsWithin_iff.mp (by simpa using hne) with ⟨r, hr, hball⟩
  refine ⟨r, hr, ?_⟩
  intro z hzU hzlt hfz
  by_contra hneq
  have hzball : z ∈ Metric.ball z0 r := by
    simpa [Metric.mem_ball, dist_eq_norm] using hzlt
  exact hfz (hball ⟨hzball, hneq⟩)