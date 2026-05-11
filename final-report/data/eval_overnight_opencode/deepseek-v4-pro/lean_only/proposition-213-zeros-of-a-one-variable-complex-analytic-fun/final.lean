
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
  have h_analytic : AnalyticOnNhd ℂ f U :=
    hf_holo.analyticOnNhd hU_open
  by_contra! h_no_disk
  have h_limit : ∀ r > (0 : ℝ), ∃ z ∈ U, ‖z - z0‖ < r ∧ f z = 0 ∧ z ≠ z0 := by
    intro r hr
    by_contra! h_no_z
    apply h_no_disk
    refine ⟨r, hr, ?_⟩
    intro z hzU hdist hfz
    by_contra! hne
    apply h_no_z
    exact ⟨z, hzU, hdist, hfz, hne⟩
  rcases Metric.isOpen_iff.mp hU_open z0 hz0U with ⟨δ, δpos, hUball⟩
  have h_frequently : ∃ᶠ (z : ℂ) in nhdsWithin z0 ({z0}ᶜ), f z = 0 := by
    rw [Filter.frequently_iff]
    intro s hs
    rcases Metric.mem_nhdsWithin_iff.mp hs with ⟨ε, hεpos, hball_inter⟩
    let r := min ε δ
    have hrpos : r > 0 := lt_min hεpos δpos
    rcases h_limit r hrpos with ⟨z, hzU, hdist, hfz, hzne⟩
    refine ⟨z, ?_, hfz⟩
    have hzball : z ∈ Metric.ball z0 ε := by
      rw [Metric.mem_ball]
      calc
        ‖z - z0‖ < r := hdist
        _ ≤ ε := min_le_left _ _
    have hzcompl : z ∈ ({z0} : Set ℂ)ᶜ := by
      simpa using hzne
    exact hball_inter ⟨hzball, hzcompl⟩
  have h_eq_zero : Set.EqOn f 0 U :=
    h_analytic.eqOn_zero_of_preconnected_of_frequently_eq_zero
      hU_connected hz0U h_frequently
  apply hf_nonzero
  exact fun z hz => h_eq_zero hz
