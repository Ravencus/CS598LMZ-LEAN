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
    have h_not_isolated : ∀ r > 0, ∃ z, z ∈ U ∧ ‖z - z0‖ < r ∧ f z = 0 ∧ z ≠ z0 := by
      intro r hr
      by_contra hcontra
      have hpr : ∀ z, z ∈ U → ‖z - z0‖ < r → f z = 0 → z = z0 := by
        intro z hzU hzdist hfz
        by_contra hzne
        exact hcontra ⟨z, hzU, hzdist, hfz, hzne⟩
      exact h_isolated ⟨r, hr, hpr⟩
    have hf_analytic : AnalyticOnNhd ℂ f U := hf_holo.analyticOnNhd hU_open
    have h_mem_closure : z0 ∈ closure ({z | f z = 0} \ {z0}) := by
      rw [Metric.mem_closure_iff]
      intro ε hε
      rcases h_not_isolated ε hε with ⟨z, hzU, hzdist, hfz, hzne⟩
      refine ⟨z, ?_, ?_⟩
      · exact ⟨hfz, hzne⟩
      · simpa [dist_eq_norm, norm_sub_rev] using hzdist
    have h_eqOn : EqOn f 0 U :=
      hf_analytic.eqOn_zero_of_preconnected_of_mem_closure hU_connected hz0U h_mem_closure
    exact hf_nonzero (fun z hz => h_eqOn hz)
