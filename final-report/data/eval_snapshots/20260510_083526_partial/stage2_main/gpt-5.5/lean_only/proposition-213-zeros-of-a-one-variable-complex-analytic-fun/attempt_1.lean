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
  by_contra h
  push_neg at h
  have hfreq : ∃ᶠ z in nhdsWithin z0 U, f z = 0 := by
    rw [frequently_iff]
    intro V hV
    rcases mem_nhdsWithin_iff_exists_mem_nhds_inter.mp hV with ⟨W, hW, hWU⟩
    rcases Metric.mem_nhds_iff.mp hW with ⟨ε, hεpos, hε⟩
    obtain ⟨z, hzU, hdist, hz0, hfz⟩ := h ε hεpos
    refine ⟨z, hWU ?_, hfz⟩
    exact ⟨hε hdist, hzU⟩
  have hid : ∀ z ∈ U, f z = 0 := by
    have hzero_diff : ∀ z ∈ U, (f - fun _ : ℂ => 0) z = 0 := by
      have hEq : EqOn f (fun _ : ℂ => 0) U :=
        DifferentiableOn.eqOn_of_preconnected_of_frequently_eq
          hU_connected hf_holo differentiableOn_const hz0U hfreq
      intro z hz
      simpa using hEq hz
    intro z hz
    simpa using hzero_diff z hz
  exact hf_nonzero hid