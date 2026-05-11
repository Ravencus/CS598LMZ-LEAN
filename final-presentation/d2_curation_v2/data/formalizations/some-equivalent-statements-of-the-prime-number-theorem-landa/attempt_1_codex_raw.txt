import Mathlib

theorem primeNumberTheoremEquivalentStatements
    (primeCounting vartheta : ℝ → ℝ) (Λ μ : ℕ → ℝ) (γ : ℝ) :
    let P1 : Prop := primeCounting ~[Filter.atTop] (fun x => x / Real.log x)
    let P2 : Prop := vartheta ~[Filter.atTop] (fun x => x)
    let P3 : Prop :=
      ((fun x : ℝ =>
          (∑ n in Finset.Icc 1 ⌊x⌋₊, Λ n / (n : ℝ)) - (Real.log x - γ)) =o[Filter.atTop]
        (fun _ : ℝ => (1 : ℝ)))
    let psiFun : ℝ → ℝ := fun x => ∑ n in Finset.Icc 1 ⌊x⌋₊, Λ n
    let P4 : Prop := psiFun ~[Filter.atTop] (fun x => x)
    let P5 : Prop :=
      ((fun x : ℝ => ∑ n in Finset.Icc 1 ⌊x⌋₊, μ n) =o[Filter.atTop] fun x => x)
    let P6 : Prop := HasSum (fun n : ℕ => μ (n + 1) / ((n + 1 : ℕ) : ℝ)) 0
    (P1 ↔ P2) ∧ (P1 ↔ P3) ∧ (P1 ↔ P4) ∧ (P1 ↔ P5) ∧ (P1 ↔ P6) := by
  sorry