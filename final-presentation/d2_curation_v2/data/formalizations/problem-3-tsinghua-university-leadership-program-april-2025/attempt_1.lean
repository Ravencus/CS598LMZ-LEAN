import Mathlib

theorem tan_pi_quarter_add_one_div_n_pow_n_tendsto :
    Filter.Tendsto
      (fun n : ℕ => (Real.tan (Real.pi / 4 + 1 / (n : ℝ))) ^ n)
      Filter.atTop
      (nhds (Real.exp 2)) := by
  sorry