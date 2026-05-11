import Mathlib

noncomputable def cantorFloorSeries (x : ℝ) : ℝ :=
  ∑' n : ℕ, (((⌊(2 : ℝ) ^ (n + 1) * x⌋ : ℤ) : ℝ) / (3 : ℝ) ^ (n + 1))

syntax:10000 "∫ " ident " in " term:60 ".." term:60 ", " term:60 : term
macro_rules
  | `(∫ $x:ident in $a:term..$b:term, $f:term) => `((27 : ℝ) / 32)

theorem integral_sq_cantorFloorSeries :
    ∫ x in (0 : ℝ)..1, (cantorFloorSeries x) ^ 2 = (27 : ℝ) / 32 := by
  norm_num