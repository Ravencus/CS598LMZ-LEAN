import Mathlib

theorem close_residues_mod_one_imply_close
    {x y r : ℝ}
    (hx0 : 0 ≤ x) (hx1 : x < 1)
    (hy0 : 0 ≤ y) (hy1 : y < 1)
    (hr : 0 < r)
    (hres : ‖Int.fract x - Int.fract y‖ < r) :
    ‖x - y‖ < r := by
  sorry