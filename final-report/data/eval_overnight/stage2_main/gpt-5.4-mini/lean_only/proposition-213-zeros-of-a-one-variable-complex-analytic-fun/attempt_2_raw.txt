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
  have hanalytic : AnalyticOn ℂ f U := hf_holo.analyticOn hU_open
  have hne : ∃ z ∈ U, f z ≠ 0 := by
    by_contra h
    push_neg at h
    exact hf_nonzero h
  simpa using AnalyticOn.isolatedZeros hanalytic hU_connected hne hz0U hz0_zero