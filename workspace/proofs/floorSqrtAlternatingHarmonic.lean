import Mathlib

open Complex
open Real
open Topology
open Finset

noncomputable section

-- Auxiliary lemma: Abel summation (summation by parts) for ℕ-indexed complex sequences
lemma abel_summation (a b : ℕ → ℂ) (N : ℕ) :
    ∑ n in range (N + 1), a n * b n =
    (∑ n in range (N + 1), a n) * b N +
    ∑ n in range N, (∑ k in range (n + 1), a k) * (b n - b (n + 1)) := by
  induction' N with M ih
  · simp
  · rw [sum_range_succ, ih, sum_range_succ, add_mul]
    ring_nf
    rw [add_comm, add_assoc]
    congr 1
    rw [sum_range_succ, add_comm, ← add_assoc, add_comm (∑ k in range (M + 1), a k * b (M + 1))]
    ring_nf

-- Bound on partial sums of the geometric series for |z|=1, z≠1
lemma geom_partial_bound (z : ℂ) (hz : ‖z‖ = 1) (hz' : z ≠ 1) (n : ℕ) :
    ‖∑ i in range n, z ^ i‖ ≤ 2 / ‖1 - z‖ := by
  have hsum : ∑ i in range n, z ^ i = (1 - z ^ n) / (1 - z) := by
    -- Use the geometric series formula from Mathlib
    rw [geom_sum₂_eq (h := hz')]
    ring
  rw [hsum]
  rw [norm_div, norm_sub, hz, norm_one]
  have h1 : ‖(1 : ℂ) - z ^ n‖ ≤ 2 := by
    calc
      ‖(1 : ℂ) - z ^ n‖ ≤ ‖(1 : ℂ)‖ + ‖z ^ n‖ := norm_sub_le _ _
      _ = 1 + ‖z‖ ^ n := by simp
      _ = 1 + 1 := by rw [hz, one_pow]
      _ = 2 := by norm_num
  have h2 : ‖1 - z‖ = ‖z - 1‖ := by rw [norm_sub, sub_sub, sub_self, sub_zero, norm_neg, norm_one]
  calc
    ‖(1 - z ^ n) / (1 - z)‖ = ‖(1 - z ^ n)‖ / ‖1 - z‖ := norm_div _ _
    _ ≤ 2 / ‖1 - z‖ := by
      refine (div_le_div_right (by exact norm_pos.mpr hz')).mpr h1
      -- need to know ‖1 - z‖ > 0, which holds since z ≠ 1 and ‖z‖ = 1
      -- But div_le_div_right expects a positivity proof
    -- Actually, the inequality for division is: a ≤ b and c > 0 => a/c ≤ b/c
    -- We can rewrite using norm_div and the bound on numerator
    sorry

-- Bound on ‖∑_{k=0}^{n} (-1)^{⌊√(k+1)⌋} z^{k+1}‖ by C√(n+1)
lemma block_partial_bound (z : ℂ) (hz : ‖z‖ = 1) (n : ℕ) :
    ‖∑ k in range (n + 1), ((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((k + 1 : ℕ) : ℝ))⌋)) * z ^ (k + 1)‖ ≤
    (Real.sqrt (n + 1 : ℝ) + 1) * (if h : z ≠ 1 then 2 / ‖1 - z‖ else (3 : ℂ).norm) := by
  sorry

-- Main theorem
theorem floorSqrtAlternatingHarmonic_powerSeries_converges_on_unitCircle :
    ∀ z : ℂ,
      ‖z‖ = 1 →
        Summable
          (fun n : ℕ =>
            (((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
              z ^ (n + 1)) := by
  intro z hz
  let f : ℕ → ℂ := fun n =>
    (((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))) *
      z ^ (n + 1)
  -- Split into two cases: z = 1 and z ≠ 1
  by_cases hz1 : z = 1
  · subst hz1
    -- When z = 1, the series is ∑_{n=0}^{∞} (-1)^{⌊√(n+1)⌋} / (n+1)
    -- This is an alternating series within blocks where ⌊√(n+1)⌋ is constant
    -- 
    -- Define the block sums and show convergence via alternating series
    let g : ℕ → ℂ := fun n => ((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) / (((n + 1 : ℕ) : ℂ))
    have hg_nonneg : ∀ n : ℕ, 0 ≤ ((g n).re) := by
      intro n
      simp [g]
    sorry
  · -- z ≠ 1, |z| = 1
    -- Use summation by parts (Abel's transformation)
    let a : ℕ → ℂ := fun n => ((-1 : ℂ) ^ (Int.toNat ⌊Real.sqrt (((n + 1 : ℕ) : ℝ))⌋)) * z ^ (n + 1)
    let b : ℕ → ℂ := fun n => ((n + 1 : ℕ) : ℂ)⁻¹
    have h_f_eq : ∀ n : ℕ, f n = a n * b n := by
      intro n
      simp [f, a, b, div_eq_mul_inv]
    -- Show f = a * b is summable using Abel transformation
    rw [h_f_eq]
    -- Build the partial sums A_n = ∑_{k=0}^{n} a_k
    let A : ℕ → ℂ := fun n => ∑ k in range (n + 1), a k
    -- Bound on A_n: ‖A_n‖ ≤ C√(n+1)
    have hA_bound : ∀ n : ℕ, ‖A n‖ ≤ (Real.sqrt (n + 1 : ℝ) + 1) * (2 / ‖1 - z‖) := by
      intro n
      have hA_form : A n = ∑ k in range (n + 1), a k := rfl
      have h_bound := block_partial_bound z hz n
      -- need to resolve the if-then-else
      sorry
    sorry
