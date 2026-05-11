import Mathlib

open scoped BigOperators

structure BernoulliIID {Ω : Type*} [MeasurableSpace Ω] (P : MeasureTheory.Measure Ω) (n : ℕ)
    (p : ℝ) (X : Fin n → Ω → ℝ) : Prop where
  indep : True
  support : ∀ i x, X i x = 0 ∨ X i x = 1
  prob_one : ∀ i, P {x | X i x = 1} = ENNReal.ofReal p

theorem bernoulli_average_distribution
    {Ω : Type*} [MeasurableSpace Ω]
    (P : MeasureTheory.Measure Ω) [MeasureTheory.IsProbabilityMeasure P]
    (n : ℕ) (hn : 0 < n)
    (p : ℝ) (hp0 : 0 ≤ p) (hp1 : p ≤ 1)
    (X : Fin n → Ω → ℝ) (hX : BernoulliIID P n p X) :
    ∀ k : ℕ,
      P {x | (∑ i : Fin n, X i x) / (n : ℝ) = (k : ℝ) / (n : ℝ)} =
        if hkn : k ≤ n then
          ENNReal.ofReal ((Nat.choose n k : ℝ) * p ^ k * (1 - p) ^ (n - k))
        else
          0 := by
  sorry