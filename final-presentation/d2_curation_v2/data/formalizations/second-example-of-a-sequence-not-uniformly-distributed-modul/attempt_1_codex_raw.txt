import Mathlib

theorem sparseRationalSequence_not_uniformlyDistributedModOne_but_dense
    (r : ℕ → ℚ)
    (hr : Set.SurjOn r Set.univ (Set.Ico (-(1 : ℚ) / 2) ((1 : ℚ) / 2))) :
    let ξ : ℕ → ℚ := fun n => if 100 ∣ n then r n else 0
    (∀ N : ℕ,
        ((Finset.Icc 1 N).filter
            (fun n => (1 : ℚ) / 5 ≤ ξ n ∧ ξ n ≤ (1 : ℚ) / 4)).card ≤ N / 100)
      ∧
        ¬ Filter.Tendsto
          (fun N : ℕ =>
            (((Finset.Icc 1 N).filter
                (fun n => (1 : ℚ) / 5 ≤ ξ n ∧ ξ n ≤ (1 : ℚ) / 4)).card : ℝ) / N)
          Filter.atTop
          (nhds ((1 : ℝ) / 20))
      ∧
        Set.Ico (-(1 : ℝ) / 2) ((1 : ℝ) / 2) ⊆
          closure (Set.range fun n : ℕ => (ξ n : ℝ)) := by
  sorry