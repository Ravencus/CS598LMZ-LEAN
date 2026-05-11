import Mathlib

theorem harmonic_log_series_diverges :
    ¬ Summable (fun n : ℕ => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2))) := by
  let f : ℕ → ℝ := fun n => 1 / (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2))
  have hnonneg : 0 ≤ᶠ[Filter.atTop] f := by
    filter_upwards with n
    dsimp [f]
    have hden : 0 < (((n : ℝ) + 2) * Real.log ((n : ℝ) + 2)) := by
      have hbase : 0 < (n : ℝ) + 2 := by positivity
      have hlog : 0 < Real.log ((n : ℝ) + 2) := by
        exact Real.log_pos (by linarith)
      exact mul_pos hbase hlog
    exact le_of_lt (one_div_pos.mpr hden)
  have hmono : ∀ᶠ k in Filter.atTop, f (k + 1) ≤ f k := by
    refine Filter.Eventually.of_forall ?_
    intro k
    dsimp [f]
    have hmono' : MonotoneOn (fun x : ℝ => x * Real.log x) (Set.Ici (2 : ℝ)) := by
      intro x hx y hy hxy
      have hx1 : (1 : ℝ) ≤ x := by
        exact le_trans (by norm_num) hx
      have hy1 : (1 : ℝ) ≤ y := by
        exact le_trans (by norm_num) hy
      simpa [mul_comm] using Real.log_mul_self_monotoneOn hx1 hy1 hxy
    have hanti : AntitoneOn (fun x : ℝ => (x * Real.log x)⁻¹) (Set.Ici (2 : ℝ)) := hmono'.inv
    have hx : (2 : ℝ) ≤ (k : ℝ) + 2 := by linarith
    have hy : (2 : ℝ) ≤ (k : ℝ) + 3 := by linarith
    have hxy : (k : ℝ) + 2 ≤ (k : ℝ) + 3 := by linarith
    have h := hanti hx hy hxy
    simpa [one_div, add_comm, add_left_comm, add_assoc, mul_comm, Nat.add_comm,
      Nat.add_left_comm, Nat.add_assoc] using h
  have hcond_not : ¬ Summable (fun k : ℕ => (2 : ℝ) ^ k * f (2 ^ k)) := by
    intro hs
    have hle : ∀ k : ℕ, (1 / 3 : ℝ) * (1 / ((k : ℝ) + 2)) ≤ (2 : ℝ) ^ k * f (2 ^ k) := by
      intro k
      dsimp [f]
      have hpow1 : (1 : ℝ) ≤ (2 : ℝ) ^ k := by
        exact one_le_pow₀ (by norm_num : (1 : ℝ) ≤ 2)
      have h1 : (1 / 3 : ℝ) ≤ ((2 : ℝ) ^ k) / (((2 : ℝ) ^ k) + 2) := by
        field_simp [show ((2 : ℝ) ^ k) + 2 ≠ 0 by positivity]
        nlinarith [hpow1]
      have hpow : ((2 : ℝ) ^ k + 2) ≤ (2 : ℝ) ^ (k + 2) := by
        rw [pow_add, pow_two]
        nlinarith [hpow1]
      have hlog2 : Real.log (((2 : ℝ) ^ k) + 2) ≤ (k : ℝ) + 2 := by
        calc
          Real.log (((2 : ℝ) ^ k) + 2) ≤ Real.log ((2 : ℝ) ^ (k + 2)) := Real.log_le_log (by positivity) hpow
          _ = ((k + 2 : ℕ) : ℝ) * Real.log 2 := by rw [Real.log_pow]
          _ ≤ (k : ℝ) + 2 := by
            have hlog2' : Real.log (2 : ℝ) ≤ 1 := by
              have h := Real.log_le_sub_one_of_pos (show 0 < (2 : ℝ) by positivity)
              linarith
            have hmul : ((k + 2 : ℕ) : ℝ) * Real.log 2 ≤ ((k + 2 : ℕ) : ℝ) * 1 := by
              gcongr
            simpa using hmul
      have h2 : 1 / ((k : ℝ) + 2) ≤ 1 / Real.log (((2 : ℝ) ^ k) + 2) := by
        exact one_div_le_one_div_of_le (by positivity) hlog2
      have hmul : (1 / 3 : ℝ) * (1 / ((k : ℝ) + 2)) ≤
          (((2 : ℝ) ^ k) / (((2 : ℝ) ^ k) + 2)) * (1 / Real.log (((2 : ℝ) ^ k) + 2)) := by
        exact mul_le_mul h1 h2 (by positivity) (by positivity)
      simpa [div_eq_mul_inv, mul_comm, mul_left_comm, mul_assoc] using hmul
    have hscaled_nonneg : ∀ k : ℕ, 0 ≤ (1 / 3 : ℝ) * (1 / ((k : ℝ) + 2)) := by
      intro k
      have h1 : 0 ≤ (1 / 3 : ℝ) := by positivity
      have hk_nonneg : 0 ≤ (k : ℝ) := by exact_mod_cast Nat.zero_le k
      have hk : 0 < (k : ℝ) + 2 := by linarith
      have h2 : 0 ≤ 1 / ((k : ℝ) + 2) := by
        exact le_of_lt (one_div_pos.mpr hk)
      exact mul_nonneg h1 h2
    have hscaled : Summable (fun k : ℕ => (1 / 3 : ℝ) * (1 / ((k : ℝ) + 2))) :=
      Summable.of_nonneg_of_le hscaled_nonneg hle hs
    have htail : Summable (fun k : ℕ => 1 / ((k : ℝ) + 2)) := by
      simpa [mul_comm, mul_left_comm, mul_assoc] using (Summable.mul_left (3 : ℝ) hscaled)
    have hnottail : ¬ Summable (fun k : ℕ => 1 / ((k : ℝ) + 2)) := by
      simpa [add_comm, add_left_comm, add_assoc] using
        (mt (_root_.summable_nat_add_iff 2).1 Real.not_summable_one_div_natCast)
    exact hnottail htail
  exact fun hs => hcond_not ((summable_condensed_iff_of_eventually_nonneg hnonneg hmono).mpr hs)