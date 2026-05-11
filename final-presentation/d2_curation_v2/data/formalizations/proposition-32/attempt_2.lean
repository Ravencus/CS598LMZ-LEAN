import Mathlib

theorem implicit_function_local_solution_taylor_expansion
    (p : ℕ) (F : ℝ × ℝ → ℝ) (sStar x0 : ℝ) (U : Set (ℝ × ℝ))
    (hU_open : IsOpen U)
    (hU_mem : (sStar, x0) ∈ U)
    (hF_smooth : ContDiffOn ℝ p F U)
    (hF_zero : F (sStar, x0) = 0)
    (hFx_ne : deriv (fun x : ℝ => F (sStar, x)) x0 ≠ 0) :
    ∃! V : Set ℝ,
      IsOpen V ∧
      sStar ∈ V ∧
      ∃ W : Set ℝ,
        IsOpen W ∧
        x0 ∈ W ∧
        ∃ x : ℝ → ℝ,
          x sStar = x0 ∧
          (∀ s, s ∈ V → F (s, x s) = 0) ∧
          Set.MapsTo x V W ∧
          ContDiffOn ℝ p x V ∧
          Asymptotics.IsLittleO (nhds sStar)
            (fun s : ℝ =>
              x s - (x sStar +
                Finset.sum (Finset.Icc 1 p) (fun i =>
                  ((iteratedDeriv i x sStar) / (i.factorial : ℝ)) * (s - sStar) ^ i)))
            (fun s : ℝ => |s - sStar| ^ p) := by
  sorry