import Mathlib

open Set

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
  by_cases h_isolated : ∃ r > 0, ∀ z, z ∈ U → ‖z - z0‖ < r → f z = 0 → z = z0
  · exact h_isolated
  · exfalso
    push_neg at h_isolated
    have h_not_isolated : ∀ r > 0, ∃ z, z ∈ U ∧ ‖z - z0‖ < r ∧ f z = 0 ∧ z ≠ z0 := by
      intro r hr
      have h := h_isolated r hr
      rcases not_forall.mp h with ⟨z, hz⟩
      rcases not_imp.mp hz with ⟨hzU, hz1⟩
      rcases not_imp.mp hz1 with ⟨hzdist, hz2⟩
      rcases not_imp.mp hz2 with ⟨hfz, hz_ne⟩
      exact ⟨z, hzU, hzdist, hfz, hz_ne⟩
    have hf_analytic : AnalyticOnNhd ℂ f U := hf_holo.analyticOnNhd hU_open
    have h_mem_closure : z0 ∈ closure ({z | f z = 0} \ {z0}) := by
      apply mem_closure_iff.mpr
      intro o ho hzo
      have ho_nhds : o ∈ 𝓝 z0 := ho.mem_nhds hzo
      rcases Metric.mem_nhds_iff.mp ho_nhds with ⟨ε, hε, hball⟩
      rcases h_not_isolated ε hε with ⟨z, hzU, hzdist, hfz, hzne⟩
      have hz_ball : z ∈ Metric.ball z0 ε := by
        rw [Metric.mem_ball, dist_eq_norm, norm_sub]
        exact hzdist
      have hz_o : z ∈ o := hball hz_ball
      have hz_s : z ∈ ({z | f z = 0} \ {z0}) := ⟨hfz, hzne⟩
      exact ⟨z, ⟨hz_o, hz_s⟩⟩
    have h_eqOn : EqOn f 0 U :=
      hf_analytic.eqOn_zero_of_preconnected_of_mem_closure hU_connected hz0U h_mem_closure
    exact hf_nonzero (fun z hz => h_eqOn hz)