import Mathlib

theorem limsup_square_not_eq_for_alternating_sequence :
    let x : ℕ → ℤ := fun n => if Even n then 1 else -2
    let clusterSet : (ℕ → ℝ) → Set ℝ := fun u =>
      {a | ∃ φ : ℕ → ℕ, StrictMono φ ∧ Filter.Tendsto (fun n => u (φ n)) Filter.atTop (nhds a)}
    sSup (clusterSet (fun n => (x n : ℝ))) = 1 ∧
      sSup (clusterSet (fun n => ((x n : ℝ) ^ 2))) = 4 ∧
      (sSup (clusterSet (fun n => (x n : ℝ)))) ^ 2 ≠
        sSup (clusterSet (fun n => ((x n : ℝ) ^ 2))) ∧
      ¬Monotone (fun y : Set.Icc (-2 : ℝ) 1 => (y : ℝ) ^ 2) := by
  sorry