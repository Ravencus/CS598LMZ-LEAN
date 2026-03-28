# Proving Trace: Complex Subset Sum

**Problem:** Given z₁, ..., zₙ complex with ∑|zᵢ| = 1, prove ∃ subset S with |∑_{k∈S} zₖ| ≥ 1/6.

**Target proofs:**
1. The 1/6 bound via quadrant method (→ actually 1/4 ≥ 1/6) — **COMPLETE**
2. The 1/π bound via averaging argument — **STRUCTURE COMPLETE, 3 sorry's in analytic core**

**Method:** Manual proving with Lean 4 + Mathlib checker in Docker.

---

## Proof 1: The 1/6 Bound (file: `06_complex_subset_sum.lean`)

### Attempt 1 — Wrong API names

**Reasoning:** Quadrant approach. Need helper lemmas for |Re z| + |Im z| ≥ ‖z‖, ‖z‖ ≥ |Re z|, ‖z‖ ≥ |Im z|. Used `Complex.norm_eq_abs`, `Complex.abs_apply`.

**Checker output:**
```
error: Unknown constant `Complex.norm_eq_abs`
```

**Analysis:** The Mathlib API names I guessed don't exist. This is the single most common failure mode: incorrect lemma names. Need to use `exact?` or `#check` to find the real names.

### API Discovery (search round)

Used `exact?` inside Docker to find:
| Needed | Found |
|--------|-------|
| ‖z‖ in terms of re, im | `Complex.norm_eq_sqrt_sq_add_sq` |
| \|z.re\| ≤ ‖z‖ | `Complex.abs_re_le_norm` |
| \|z.im\| ≤ ‖z‖ | `Complex.abs_im_le_norm` |
| ‖z‖ ≤ \|z.re\| + \|z.im\| | `Complex.norm_le_abs_re_add_abs_im` |
| z.re ≤ ‖z‖ | `Complex.re_le_norm` |
| (∑ zᵢ).re = ∑(zᵢ).re | `Complex.re_sum` |
| (∑ zᵢ).im = ∑(zᵢ).im | `Complex.im_sum` |
| -x ≤ \|x\| | `neg_le_abs` |
| x ≤ \|x\| | `le_abs_self` |
| ∑(-fᵢ) = -(∑fᵢ) | `Finset.sum_neg_distrib` |
| ∑(fᵢ+gᵢ) = ∑fᵢ + ∑gᵢ | `Finset.sum_add_distrib` |
| \|x\| = x when x ≥ 0 | `abs_of_nonneg` |
| \|x\| = -x when x < 0 | `abs_of_neg` |

**Lesson:** `exact?` is the essential tool for Mathlib API discovery. Guessing names wastes cycles.

### Attempt 2 — Structure compiles, but helper lemma and main proof fail

**Reasoning:** Wrote `sum_abs_eq_pos_neg_parts` to split ∑|f i| into positive/negative parts. Main proof uses four-way case split.

**Checker output:**
```
error: Unknown identifier `abs_eq_ite`
error: failed to synthesize Decidable ¬?p
error: simp made no progress
error: linarith failed to find a contradiction
```

**Analysis:**
1. `abs_eq_ite` doesn't exist — replaced with `abs_of_nonneg`/`abs_of_neg` + `Finset.sum_congr`
2. Decidability: `Finset.sum_filter_add_sum_filter_not` needs both `DecidablePred p` and `Decidable ¬p`. Fixed by using `Finset.filter_congr` with `not_le.symm` to bridge `f i < 0 ↔ ¬(0 ≤ f i)`.
3. Nonneg for negative parts: `Finset.sum_nonneg` needs explicit `linarith` since the filter predicate gives `f i < 0`, not `- f i ≥ 0`.
4. `linarith` scope: needed to restructure `a + b + c + d ≥ 1` as `(a + b) + (c + d) ≥ 1` with explicit intermediate equalities via `h_ab`, `h_cd`, and `Finset.sum_add_distrib`.

### Attempt 3 — Predicate form mismatch

**Checker output:**
```
error: Type mismatch — sum_abs_eq_pos_neg_parts returns with predicate `0 ≤ f i`
but S_rp was defined with `(z i).re ≥ 0`
```

**Analysis:** `≥ 0` and `0 ≤` are definitionally the same but cause unification issues when matching `set` definitions against lemma conclusions. Changed all four filter predicates to use `0 ≤ ...` form.

### Attempt 3b — Success

**Checker output:** No errors, no warnings.

**Result: PROOF COMPLETE** ✓

**File:** `workspace/problems/06_complex_subset_sum.lean`

**Proof structure:**
```
sum_abs_eq_pos_neg_parts (helper)
  └→ complex_subset_sum (main theorem)
       ├→ Define S_rp, S_rn, S_ip, S_in (four half-planes)
       ├→ ha, hb, hc, hd ≥ 0 (non-negativity)
       ├→ h_ab, h_cd (= ∑|Re|, ∑|Im|)
       ├→ sum_ge : a+b+c+d ≥ 1 (via norm_le_abs_re_add_abs_im)
       └→ Four-way case split, each via calc chain:
            ‖∑z‖ ≥ |Re or Im component| ≥ sum ≥ 1/4 ≥ 1/6
```

**Iterations:** 4 (1 wrong API → 1 search → 1 structural fix → 1 predicate fix)

**Key difficulties:**
1. Mathlib API discovery (the biggest time sink)
2. `≥ 0` vs `0 ≤` predicate matching
3. Connecting sum decompositions through `linarith`
4. Direction of equalities (`.symm` needed for `Finset.sum_neg_distrib`)

---

## Proof 2: The 1/π Bound (file: `07_complex_subset_sum_pi.lean`)

### Strategy

Averaging argument over all directions α ∈ [0, 2π):
1. For each α, take S_α = {k : Re(zₖ·e^{-iα}) ≥ 0}
2. F(α) = ∑_{k∈S_α} Re(zₖ·e^{-iα}) = ∑_k max(Re(zₖ·e^{-iα}), 0)
3. ∫₀²π F(α) dα = ∑_k ‖zₖ‖ · 2 = 2
4. By mean value: ∃ α₀ with F(α₀) ≥ 2/(2π) = 1/π
5. ‖∑_{S_{α₀}} zₖ‖ ≥ F(α₀) ≥ 1/π

### Attempt 1 — Multiple API issues

**Checker output:**
```
error: Unknown constant `intervalIntegral.integral_lt_of_lt_of_continuousOn_of_isClosed`
error: No goals to be solved (ring after simp already closed it)
error: re_mul_exp_neg — simp couldn't handle exp(-iα) decomposition
error: norm_ge_re_mul_exp — Complex.norm_exp_ofReal_mul_I pattern mismatch
```

**Analysis:**
1. `integral_lt_of_...` doesn't exist — need different approach to mean value theorem
2. `re_mul_exp_neg`: need to rewrite `-(α·I)` as `(-α)·I` first, then use `Complex.exp_ofReal_mul_I_re/im` with `Real.cos_neg`/`Real.sin_neg`
3. `norm_ge_re_mul_exp`: same rewrite trick for `‖exp((-α)·I)‖ = 1`, then `norm_mul` + `mul_one`

### Attempt 2 — Fixed lemmas, sorry'd analytic core

**Key fixes:**
- `re_mul_exp_neg`: rewrite `-(↑α * I) = ↑(-α) * I` via `push_cast; ring`, then use standard Mathlib lemmas
- `norm_exp_neg_I`: same rewrite trick
- `norm_ge_re_mul_exp`: factored through `norm_mul` + `norm_exp_neg_I`
- Separated `sorry`'d analytic lemmas from proved algebraic lemmas

**Checker output:** 3 `sorry` warnings, no errors.

**Result: STRUCTURE COMPLETE** — 3 sorry's remain in analytic core

### What's proved vs sorry'd

**Proved (no sorry):**
| Lemma | Statement |
|-------|-----------|
| `norm_exp_neg_I` | ‖exp(-iα)‖ = 1 |
| `re_mul_exp_neg` | Re(z·exp(-iα)) = z.re·cosα + z.im·sinα |
| `norm_ge_re_mul_exp` | ‖w‖ ≥ Re(w·exp(-iα)) |
| `subset_norm_ge_sum_re` | ‖∑_S z‖ ≥ ∑_S Re(z·exp(-iα)) |
| `complex_subset_sum_pi` | Final assembly: ∃ S, ‖∑_S z‖ ≥ 1/π |

**Sorry'd (analytic core):**
| Lemma | Statement | What's needed |
|-------|-----------|---------------|
| `integral_max_cos` | ∫₀²π max(cos u, 0) du = 2 | Split integral at π/2 and 3π/2, FTC on each piece |
| `exists_ge_avg_of_integral` | Mean value theorem for integrals | Contradiction via `intervalIntegral.integral_mono` |
| `averaging_argument` | ∃ α₀, F(α₀) ≥ 1/π | Combines above two + Fubini (sum/integral swap) |

### Why the analytic core is hard

1. **`integral_max_cos`**: Requires splitting [0, 2π] into subintervals where cos is positive/negative, showing max(cos, 0) = cos or 0 on each, applying FTC. The FTC step itself works (verified: ∫ cos from -π/2 to π/2 = 2 compiles). The splitting and case analysis is the tedious part.

2. **`exists_ge_avg_of_integral`**: Proof by contradiction. If ∀ x, f(x) < C/(b-a), then ∫f < C. Need strict integral bound, which Mathlib may not have directly (only found `intervalIntegral.integral_mono` for ≤).

3. **`averaging_argument`**: Requires Fubini to swap ∑_k and ∫dα, plus the substitution u = θ_k - α to reduce each inner integral to `integral_max_cos`. Also needs to express z_k in polar form (z_k = ‖z_k‖ · e^{iθ_k}).

**Estimated effort to close sorry's:** Each would take several hours of Lean formalization. The algebraic structure (what makes the proof work) is fully verified.

---

## Summary

| Proof | File | Status | Sorry count |
|-------|------|--------|-------------|
| 1/6 (quadrant) | `06_complex_subset_sum.lean` | **COMPLETE** | 0 |
| 1/π (averaging) | `07_complex_subset_sum_pi.lean` | **Structure complete** | 3 |

**Total checker invocations:** ~15 (including API searches)
**Total iterations for Proof 1:** 4
**Total iterations for Proof 2:** 2

**Key meta-observations:**
1. API discovery is the dominant cost — knowing the right lemma name is half the battle
2. Lean's definitional equality is strict in practice — `≥ 0` vs `0 ≤` causes real failures
3. The algebraic/combinatorial skeleton of a proof is much easier to formalize than the analytic parts
4. `calc` chains are the most readable and debuggable proof structure
5. The quadrant proof (1/4) is dramatically simpler to formalize than the averaging proof (1/π), even though the averaging proof is more elegant on paper
