import Mathlib

theorem legendre_formula_and_indicator_decomposition (p n : ℕ) (hp : p.Prime) :
    (padicValNat p (Nat.factorial n) = Finset.sum (Finset.Icc 1 n) (fun m => padicValNat p m)) ∧
    (∀ m ∈ Finset.Icc 1 n,
      padicValNat p m = Finset.sum (Finset.Icc 1 m) (fun k => if p ^ k ∣ m then 1 else 0)) ∧
    (padicValNat p (Nat.factorial n) = Finset.sum (Finset.Icc 1 n) (fun k => n / p ^ k)) := by
  sorry