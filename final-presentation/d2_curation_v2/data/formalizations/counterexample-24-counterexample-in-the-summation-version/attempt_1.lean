import Mathlib

abbrev Omega := {n : ℕ // 1 ≤ n}

def f (i j : Omega) : ℝ :=
  if i.1 = j.1 then 1 else if i.1 = j.1 + 1 then -1 else 0

theorem countingMeasureFubiniCounterexample :
    ¬ Summable (fun p : Omega × Omega => |f p.1 p.2|) ∧
      (∑' i : Omega, ∑' j : Omega, f i j) = 1 ∧
      (∑' j : Omega, ∑' i : Omega, f i j) = 0 := by
  sorry