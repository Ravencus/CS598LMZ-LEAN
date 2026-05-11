import Mathlib

open scoped BigOperators

theorem totient_sum_mul_natDiv_eq_triangular (n : ℕ) :
    Finset.sum (Finset.Icc 1 n) (fun k => Nat.totient k * (n / k)) = n * (n + 1) / 2 := by
  sorry

theorem moebius_sum_mul_natDiv_eq_one {n : ℕ} (hn : 1 ≤ n) :
    Finset.sum (Finset.Icc 1 n) (fun k => ArithmeticFunction.moebius k * ((n / k : ℕ) : ℤ)) = 1 := by
  sorry

theorem distinctPrimeFactorParity_sum_mul_natDiv_eq_factorizationProduct (n : ℕ) :
    Finset.sum (Finset.Icc 1 n)
        (fun k =>
          ((-1 : ℤ) ^ (ArithmeticFunction.cardDistinctFactors k)) * ((n / k : ℕ) : ℤ)) =
      Finset.sum (Finset.Icc 1 n)
        (fun m => Finset.prod m.primeFactors (fun p => (1 - (m.factorization p : ℤ)))) := by
  sorry