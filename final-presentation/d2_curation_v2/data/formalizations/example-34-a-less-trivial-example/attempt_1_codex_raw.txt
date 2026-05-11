import Mathlib

def LimsupAtTop (f : ℝ → ℝ) (L : ℝ) : Prop :=
  (∀ ε : ℝ, 0 < ε → ∀ᶠ x in Filter.atTop, f x < L + ε) ∧
    ∀ ε : ℝ, 0 < ε → ∀ R : ℝ, ∃ x : ℝ, R ≤ x ∧ L - ε < f x

def LiminfAtTop (f : ℝ → ℝ) (L : ℝ) : Prop :=
  (∀ ε : ℝ, 0 < ε → ∀ᶠ x in Filter.atTop, L - ε < f x) ∧
    ∀ ε : ℝ, 0 < ε → ∀ R : ℝ, ∃ x : ℝ, R ≤ x ∧ f x < L + ε

theorem sinQuadratic_limsup_liminf :
    let f : ℝ → ℝ := fun x => (1 + 1 / x) * Real.sin (x ^ 2)
    LimsupAtTop f 1 ∧
      LiminfAtTop f (-1) ∧
      (∃ xseq : ℕ → ℝ,
        Filter.Tendsto xseq Filter.atTop Filter.atTop ∧
          (∀ n : ℕ,
            1 ≤ xseq n ∧
              (xseq n) ^ 2 = Real.pi / 2 + 2 * Real.pi * (n : ℝ)) ∧
          Filter.Tendsto (fun n => f (xseq n)) Filter.atTop (nhds 1)) ∧
      (∃ yseq : ℕ → ℝ,
        Filter.Tendsto yseq Filter.atTop Filter.atTop ∧
          (∀ n : ℕ,
            1 ≤ yseq n ∧
              (yseq n) ^ 2 = 3 * Real.pi / 2 + 2 * Real.pi * (n : ℝ)) ∧
          Filter.Tendsto (fun n => f (yseq n)) Filter.atTop (nhds (-1)))
  := by
    sorry