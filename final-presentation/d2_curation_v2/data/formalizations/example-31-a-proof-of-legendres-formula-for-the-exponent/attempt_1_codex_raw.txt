import Mathlib

theorem legendre_formula_and_indicator_decomposition (p n : ℕ) (hp : p.Prime) :
    (padicValNat p n.factorial = ∑ m in Finset.Icc 1 n, padicValNat p m) ∧
    (∀ m ∈ Finset.Icc 1 n,
      padicValNat p m = ∑ k in Finset.Icc 1 m, if p ^ k ∣ m then 1 else 0) ∧
    (padicValNat p n.factorial = ∑ k in Finset.Icc 1 n, n / p ^ k) := by
  sorry