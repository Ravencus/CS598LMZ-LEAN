import Mathlib

theorem periodic_average_limit
    {f g : ℝ → ℝ} {a b T : ℝ}
    (hf : IntervalIntegrable f volume a b)
    (hg_meas : Measurable g)
    (hg_bdd : ∃ C : ℝ, ∀ x : ℝ, ‖g x‖ ≤ C)
    (hg_per : Function.Periodic g T)
    (hT : 0 < T) :
    Filter.Tendsto
      (fun n : ℕ => ∫ x in a..b, f x * g ((n : ℝ) * x))
      Filter.atTop
      (nhds
        (((1 / T) * (∫ x in Set.Ioc 0 T, g x)) * (∫ x in a..b, f x))) := by
  sorry