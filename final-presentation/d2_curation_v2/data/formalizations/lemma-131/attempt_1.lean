import Mathlib

theorem real_riemann_integrable_approx_by_continuous_complex
    (f : ℝ → ℝ)
    (hf : IntervalIntegrable f volume (-(1 : ℝ) / 2) ((1 : ℝ) / 2)) :
    ∀ ε > 0, ∃ g : ℝ → ℂ,
      ContinuousOn g (Set.Icc (-(1 : ℝ) / 2) ((1 : ℝ) / 2)) ∧
      IntervalIntegrable (fun x : ℝ => ‖((f x : ℂ) - g x)‖) volume (-(1 : ℝ) / 2) ((1 : ℝ) / 2) ∧
      (∫ x in (-(1 : ℝ) / 2)..((1 : ℝ) / 2), ‖((f x : ℂ) - g x)‖ ∂volume) < ε := by
  sorry