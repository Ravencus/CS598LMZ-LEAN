import Mathlib
open Set
#check Set.Icc (0:ℝ) 1 ⊆ closure (Set.range (fun (n:ℕ) => (0:ℝ)))