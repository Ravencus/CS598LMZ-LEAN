import Mathlib

abbrev Torus : Type := { z : ℂ // ‖z‖ = (1 : ℝ) }

theorem unitCircle_polynomial_uniform_approximation
    (f : Torus → ℂ) (hf : Continuous f) :
    ∀ ε : ℝ, ε > 0 → ∃ P : Polynomial ℂ, ∀ z : Torus, ‖f z - P.eval z.1‖ < ε := by
  intro ε hε
  classical
  let K : Set ℂ := { z : ℂ | ‖z‖ = (1 : ℝ) }
  let g : C(K, ℂ) := ⟨fun z => f ⟨z.1, z.2⟩, by
    rw [continuous_iff_continuousAt]
    intro z
    exact hf.continuousAt.comp (continuousAt_subtype_val)⟩
  obtain ⟨P, hP⟩ :=
    Polynomial.exists_forall_norm_sub_lt_of_isCompact
      (s := K) (isCompact_isClosed (isClosed_eq continuous_norm continuous_const))
      g hε
  refine ⟨P, ?_⟩
  intro z
  simpa [K, g, dist_eq_norm, norm_sub_rev] using hP ⟨z.1, z.2⟩