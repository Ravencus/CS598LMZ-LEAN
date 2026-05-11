import Mathlib
open Polynomial

example (α : ℝ) : Monic (X - C α : Polynomial ℝ) := monic_X_sub_C α