import Mathlib

def oneOverSeq : ℕ → ℚ
  | 0 => 1
  | n + 1 => 1 / ((n + 1 : ℕ) : ℚ)

def centeredReductionModOne (x : ℚ) : ℚ :=
  if x = 1 then
    0
  else if x = (1 / 2 : ℚ) then
    -(1 / 2 : ℚ)
  else
    x

theorem one_over_n_not_uniformly_distributed_mod_one :
    centeredReductionModOne (oneOverSeq 0) = 0 ∧
    centeredReductionModOne (oneOverSeq 1) = -(1 / 2 : ℚ) ∧
    (∀ n : ℕ, 2 ≤ n → centeredReductionModOne (oneOverSeq n) = 1 / ((n : ℕ) : ℚ)) ∧
    Filter.Tendsto
      (fun N : ℕ =>
        (((Finset.range N).filter
            (fun k => centeredReductionModOne (oneOverSeq k) ∈ Set.Icc (-(1 / 2 : ℚ)) 0)).card : ℚ) /
          (N : ℚ))
      Filter.atTop
      (𝓝 (0 : ℚ)) := by
  sorry