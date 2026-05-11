import Mathlib

theorem dense_mod_one_of_unbounded_pos_deriv_antitone_tendsto_zero
    (f : ℝ → ℝ)
    (hunbounded : ∀ M : ℝ, ∃ x ≥ (1 : ℝ), M < f x)
    (hderiv_pos : ∀ x ≥ (1 : ℝ), 0 < deriv f x)
    (hderiv_antitone : AntitoneOn (deriv f) (Set.Ici (1 : ℝ)))
    (hderiv_tendsto : Filter.Tendsto (deriv f) Filter.atTop (nhds (0 : ℝ))) :
    DenseRange
      (fun n : ℕ =>
        ((⟨Int.fract (f n), ⟨Int.fract_nonneg (f n), le_of_lt (Int.fract_lt_one (f n))⟩⟩ :
          Set.Icc (0 : ℝ) 1))) := by
  sorry