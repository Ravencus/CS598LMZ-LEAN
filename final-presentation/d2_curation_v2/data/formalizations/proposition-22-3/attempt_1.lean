import Mathlib

theorem sinPower_limsup_liminf :
    let a : ℕ → ℝ := fun n => (((2 : ℝ) / 3) + ((1 : ℝ) / 3) * Real.sin (n : ℝ)) ^ n
    let clusterSet : Set ℝ :=
      {x : ℝ |
        ∃ φ : ℕ → ℕ, StrictMono φ ∧
          Filter.Tendsto (fun n => a (φ n)) Filter.atTop (nhds x)}
    sSup clusterSet = 1 ∧ sInf clusterSet = 0 := by
  sorry