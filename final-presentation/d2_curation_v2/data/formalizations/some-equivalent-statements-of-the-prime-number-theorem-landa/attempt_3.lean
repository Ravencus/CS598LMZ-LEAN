import Mathlib

theorem primeNumberTheoremEquivalentStatements
    (primeCounting vartheta : ℝ → ℝ) (Λ μ : ℕ → ℝ) (γ : ℝ) :
    let P1 : Prop := Asymptotics.IsEquivalent Filter.atTop primeCounting (fun x => x / Real.log x)
    let P2 : Prop := Asymptotics.IsEquivalent Filter.atTop vartheta (fun x => x)
    let P3 : Prop :=
      Asymptotics.IsLittleO Filter.atTop
        (fun x : ℝ =>
          (∑ n in Finset.Icc 1 ⌊x⌋₊, Λ n / (n : ℝ)) - (Real.log x - γ))
        (fun _ : ℝ => (1 : ℝ))
    let psiFun : ℝ → ℝ := fun x => ∑ n in Finset.Icc 1 ⌊x⌋₊, Λ n
    let P4 : Prop := Asymptotics.IsEquivalent Filter.atTop psiFun (fun x => x)
    let P5 : Prop :=
      Asymptotics.IsLittleO Filter.atTop
        (fun x : ℝ => ∑ n in Finset.Icc 1 ⌊x⌋₊, μ n)
        (fun x => x)
    let P6 : Prop := HasSum (fun n : ℕ => μ (n + 1) / (n + 1 : ℝ)) 0
    (P1 ↔ P2) ∧ (P1 ↔ P3) ∧ (P1 ↔ P4) ∧ (P1 ↔ P5) ∧ (P1 ↔ P6) := by
  sorry