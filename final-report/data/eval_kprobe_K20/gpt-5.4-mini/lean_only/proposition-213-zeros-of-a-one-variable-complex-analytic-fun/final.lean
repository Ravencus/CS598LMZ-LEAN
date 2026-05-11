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
  have hU_conn : IsConnected U := ⟨hU_nonempty, hU_connected⟩
  have hf_an : AnalyticOnNhd ℂ f U := hf_holo.analyticOnNhd hU_open
  have h_nonzero : ∃ x ∈ U, f x ≠ 0 := by
    by_contra h
    have h_all : ∀ z ∈ U, f z = 0 := by
      intro z hz
      by_contra hz0
      exact h ⟨z, hz, hz0⟩
    exact hf_nonzero h_all
  rcases h_nonzero with ⟨x, hxU, hxf⟩
  have hcod : {z : ℂ | f z ≠ 0} ∈ Filter.codiscreteWithin U := by
    simpa [Set.preimage, Set.compl_setOf] using
      (hf_an.preimage_zero_mem_codiscreteWithin (x := x) hxf hxU hU_conn)
  have hdisc : IsDiscrete ({z : ℂ | f z = 0} ∩ U) := by
    simpa [Set.compl_setOf] using
      (isDiscrete_of_codiscreteWithin (s := {z : ℂ | f z = 0}) (U := U) hcod)
  obtain ⟨r, hr, hball⟩ := Metric.exists_ball_inter_eq_singleton_of_mem_discrete hdisc
    (by exact ⟨hz0_zero, hz0U⟩)
  refine ⟨r, hr, ?_⟩
  intro z hzU hzlt hzero
  have hz_mem : z ∈ Metric.ball z0 r ∩ ({w : ℂ | f w = 0} ∩ U) := by
    refine ⟨?_, ⟨hzero, hzU⟩⟩
    simpa [Metric.mem_ball, dist_eq_norm] using hzlt
  have hz_single : z ∈ ({z0} : Set ℂ) := by
    simpa [hball] using hz_mem
  simpa using hz_single