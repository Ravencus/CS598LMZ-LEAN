import Mathlib

/-
Proof of the 1/π bound via the averaging/probabilistic method.

Strategy: For each direction α ∈ [0, 2π), take S_α = indices whose projection
onto direction α is non-negative. Define F(α) = ∑_k ‖z_k‖ · max(cos(θ_k - α), 0).
Then:
  (a) F(α) ≤ ‖∑_{k∈S_α} z_k‖  for all α
  (b) ∫₀²π F(α) dα = 2
So ∃ α₀ with F(α₀) ≥ 2/(2π) = 1/π, hence ‖∑_{S_{α₀}} z_k‖ ≥ 1/π.
-/

/-
## Sorry'd lemmas (analytic core)

These require integration machinery (FTC, Fubini, splitting integrals at zeros)
that is available in Mathlib but requires substantial formalization effort.
-/

-- Key integral: ∫₀²π max(cos u, 0) du = 2
lemma integral_max_cos :
    ∫ u in (0 : ℝ)..(2 * Real.pi), max (Real.cos u) 0 = 2 := by
  sorry

-- Mean value for integrals on a compact interval
lemma exists_ge_avg_of_integral {f : ℝ → ℝ} {a b C : ℝ}
    (hab : a < b) (hf_cont : ContinuousOn f (Set.Icc a b))
    (hf_nn : ∀ x ∈ Set.Icc a b, 0 ≤ f x)
    (hf_int : ∫ x in a..b, f x = C) :
    ∃ x ∈ Set.Icc a b, f x ≥ C / (b - a) := by
  sorry

/-
## Proved lemmas (algebraic structure)
-/

-- ‖exp(αi)‖ = 1
lemma norm_exp_neg_I (α : ℝ) :
    ‖Complex.exp (-(↑α * Complex.I))‖ = 1 := by
  rw [show -(↑α * Complex.I) = ↑(-α) * Complex.I from by push_cast; ring]
  exact Complex.norm_exp_ofReal_mul_I (-α)

-- Re(z · exp(-iα)) = z.re cos α + z.im sin α
lemma re_mul_exp_neg (z : ℂ) (α : ℝ) :
    (z * Complex.exp (-(↑α * Complex.I))).re = z.re * Real.cos α + z.im * Real.sin α := by
  have hre : (Complex.exp (-(↑α * Complex.I))).re = Real.cos α := by
    rw [show -(↑α * Complex.I) = ↑(-α) * Complex.I from by push_cast; ring]
    rw [Complex.exp_ofReal_mul_I_re, Real.cos_neg]
  have him : (Complex.exp (-(↑α * Complex.I))).im = -Real.sin α := by
    rw [show -(↑α * Complex.I) = ↑(-α) * Complex.I from by push_cast; ring]
    rw [Complex.exp_ofReal_mul_I_im, Real.sin_neg]
  simp [Complex.mul_re, hre, him]

-- ‖w‖ ≥ Re(w · exp(-iα))
lemma norm_ge_re_mul_exp (w : ℂ) (α : ℝ) :
    ‖w‖ ≥ (w * Complex.exp (-(↑α * Complex.I))).re := by
  have h1 : ‖w * Complex.exp (-(↑α * Complex.I))‖ = ‖w‖ := by
    rw [norm_mul, norm_exp_neg_I, mul_one]
  calc ‖w‖ = ‖w * Complex.exp (-(↑α * Complex.I))‖ := h1.symm
    _ ≥ (w * Complex.exp (-(↑α * Complex.I))).re := Complex.re_le_norm _

-- For any subset S and angle α:
-- ‖∑_{k∈S} z_k‖ ≥ ∑_{k∈S} Re(z_k · exp(-iα))
lemma subset_norm_ge_sum_re {n : ℕ} (z : Fin n → ℂ) (S : Finset (Fin n)) (α : ℝ) :
    ‖∑ i ∈ S, z i‖ ≥ ∑ i ∈ S, (z i * Complex.exp (-(↑α * Complex.I))).re := by
  calc ‖∑ i ∈ S, z i‖
      ≥ ((∑ i ∈ S, z i) * Complex.exp (-(↑α * Complex.I))).re :=
        norm_ge_re_mul_exp _ _
    _ = (∑ i ∈ S, z i * Complex.exp (-(↑α * Complex.I))).re := by
        rw [Finset.sum_mul]
    _ = ∑ i ∈ S, (z i * Complex.exp (-(↑α * Complex.I))).re :=
        Complex.re_sum S _

/-
## Main theorem
-/

-- The averaging argument (sorry'd — requires integral_max_cos + Fubini + exists_ge_avg)
-- States: ∃ direction α₀ such that the positive-projection subset S_{α₀} satisfies
-- ∑_{k∈S_{α₀}} Re(z_k · e^{-iα₀}) ≥ 1/π
lemma averaging_argument {n : ℕ} (z : Fin n → ℂ) (h : ∑ i, ‖z i‖ = 1) :
    ∃ α : ℝ,
      ∑ i ∈ Finset.univ.filter
        (fun k => 0 ≤ (z k * Complex.exp (-(↑α * Complex.I))).re),
        (z i * Complex.exp (-(↑α * Complex.I))).re ≥ 1 / Real.pi := by
  -- Proof sketch (requires integration):
  -- Define F(α) = ∑_k ‖z_k‖ · max(Re(z_k/‖z_k‖ · e^{-iα}), 0)
  --            = ∑_k max(Re(z_k · e^{-iα}), 0)   [when z_k ≠ 0, scale by ‖z_k‖]
  -- Note: ∑_{k∈S_α} Re(z_k·e^{-iα}) = ∑_k max(Re(z_k·e^{-iα}), 0) = F(α)
  --   because Re(z_k·e^{-iα}) ≥ 0 iff k ∈ S_α, and the negative terms are excluded.
  --
  -- ∫₀²π F(α) dα = ∑_k ∫₀²π max(Re(z_k·e^{-iα}), 0) dα
  --              = ∑_k ‖z_k‖ · ∫₀²π max(cos(θ_k - α), 0) dα   [where z_k = ‖z_k‖·e^{iθ_k}]
  --              = ∑_k ‖z_k‖ · 2                                 [by integral_max_cos + periodicity]
  --              = 2 · 1 = 2
  --
  -- By exists_ge_avg: ∃ α₀ with F(α₀) ≥ 2/(2π) = 1/π.
  sorry

theorem complex_subset_sum_pi (n : ℕ) (z : Fin n → ℂ)
    (h : ∑ i, ‖z i‖ = 1) :
    ∃ S : Finset (Fin n), ‖∑ i ∈ S, z i‖ ≥ 1 / Real.pi := by
  obtain ⟨α₀, hα₀⟩ := averaging_argument z h
  set S₀ := Finset.univ.filter
    (fun k => 0 ≤ (z k * Complex.exp (-(↑α₀ * Complex.I))).re)
  exact ⟨S₀, le_trans hα₀ (subset_norm_ge_sum_re z S₀ α₀)⟩
