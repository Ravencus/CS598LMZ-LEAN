import Mathlib

theorem riemannIntegrable_iff_exists_intervalIntegrable_bounds
    {a b : ℝ} {f : ℝ → ℝ} :
    IntervalIntegrable f volume a b ↔
      ∀ ε > 0, ∃ α β : ℝ → ℝ,
        IntervalIntegrable α volume a b ∧
        IntervalIntegrable β volume a b ∧
        (∀ x ∈ Set.Icc a b, α x ≤ f x) ∧
        (∀ x ∈ Set.Icc a b, f x ≤ β x) ∧
        |∫ x in a..b, (α x - β x)| < ε := by
  constructor
  · intro hf ε hε
    refine ⟨f, f, hf, hf, ?_, ?_, ?_⟩
    · intro x hx
      rfl
    · intro x hx
      rfl
    · simpa using hε
  · intro h
    refine (intervalIntegrable_iff_lowerIntervalIntegral_eq_upperIntervalIntegral).2 ?_
    apply le_antisymm
    · exact lowerIntervalIntegral_le_upperIntervalIntegral f volume a b
    · by_contra hgt
      have hlt : lowerIntervalIntegral f volume a b < upperIntervalIntegral f volume a b :=
        lt_of_not_ge hgt
      let ε : ℝ := (upperIntervalIntegral f volume a b - lowerIntervalIntegral f volume a b) / 2
      have hεpos : ε > 0 := by
        dsimp [ε]
        linarith
      rcases h ε hεpos with ⟨α, β, hα, hβ, hαf, hfβ, hgap⟩
      have hαβ : ∀ x ∈ Set.Icc a b, α x ≤ β x := by
        intro x hx
        linarith [hαf x hx, hfβ x hx]
      have hlower : ∫ x in a..b, α x ≤ lowerIntervalIntegral f volume a b := by
        simpa [lowerIntervalIntegral_eq_integral hα] using
          (lowerIntervalIntegral_mono hαf)
      have hupper : upperIntervalIntegral f volume a b ≤ ∫ x in a..b, β x := by
        simpa [upperIntervalIntegral_eq_integral hβ] using
          (upperIntervalIntegral_mono hfβ)
      have hβnonneg : 0 ≤ ∫ x in a..b, (β x - α x) := by
        exact integral_nonneg (by
          intro x hx
          exact sub_nonneg.mpr (hαβ x hx))
      have hgapβ : |∫ x in a..b, (β x - α x)| < ε := by
        have hnegfun : (fun x => α x - β x) = fun x => -(β x - α x) := by
          funext x
          ring
        have hgap' := hgap
        rw [hnegfun, integral_neg, abs_neg] at hgap'
        simpa using hgap'
      have hgapβ' : ∫ x in a..b, (β x - α x) < ε := by
        simpa [abs_of_nonneg hβnonneg] using hgapβ
      have hdiff : upperIntervalIntegral f volume a b - lowerIntervalIntegral f volume a b
          ≤ ∫ x in a..b, (β x - α x) := by
        linarith
      have hfinal : upperIntervalIntegral f volume a b - lowerIntervalIntegral f volume a b < ε := by
        exact lt_of_le_of_lt hdiff hgapβ'
      dsimp [ε] at hfinal
      linarith