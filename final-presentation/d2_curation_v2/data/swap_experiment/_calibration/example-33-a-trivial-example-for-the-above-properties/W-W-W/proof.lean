import Mathlib

theorem sin_limsup_liminf_atTop_and_sequences :
    Filter.limsup Real.sin Filter.atTop = 1 ∧
    Filter.liminf Real.sin Filter.atTop = -1 ∧
    let x : ℕ → ℝ := fun n => Real.pi / 2 + 2 * Real.pi * (n : ℝ)
    let y : ℕ → ℝ := fun n => 3 * Real.pi / 2 + 2 * Real.pi * (n : ℝ)
    Filter.Tendsto (fun n => Real.sin (x n)) Filter.atTop (nhds 1) ∧
      Filter.Tendsto (fun n => Real.sin (y n)) Filter.atTop (nhds (-1)) := by
  constructor
  · exact Real.limsup_sin_atTop
  constructor
  · exact Real.liminf_sin_atTop
  dsimp
  constructor
  · have hx :
        (fun n : ℕ => Real.sin (Real.pi / 2 + 2 * Real.pi * (n : ℝ))) =
          fun _ => (1 : ℝ) := by
        funext n
        have h := Real.sin_add_int_mul_two_pi (Real.pi / 2) (n : ℤ)
        simpa [mul_comm, mul_left_comm, mul_assoc, Real.sin_pi_div_two] using h
    simpa [hx] using
      (tendsto_const_nhds : Filter.Tendsto (fun _ : ℕ => (1 : ℝ)) Filter.atTop (nhds 1))
  · have hy :
        (fun n : ℕ => Real.sin (3 * Real.pi / 2 + 2 * Real.pi * (n : ℝ))) =
          fun _ => (-1 : ℝ) := by
        funext n
        have h := Real.sin_add_int_mul_two_pi (3 * Real.pi / 2) (n : ℤ)
        simpa [mul_comm, mul_left_comm, mul_assoc, Real.sin_three_pi_div_two] using h
    simpa [hy] using
      (tendsto_const_nhds : Filter.Tendsto (fun _ : ℕ => (-1 : ℝ)) Filter.atTop (nhds (-1)))