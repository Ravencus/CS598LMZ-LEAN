# Strong vs weak: harmonic-sequence divergence

**Problem:** prove `¬ ∃ l : ℝ, Tendsto harmonicSeq atTop (nhds l)` where `harmonicSeq n = ∑_{k ∈ Icc 1 n} 1/k`.

Both runs use the **identical** Stage 7 verified theorem signature and the **identical** outer feedback pattern: write Lean → `lake env lean` → feed top-8 diagnostics back as context for the next round, up to K rounds.

The difference is the model and the harness:

| | Strong baseline | Weak baseline |
|--|--|--|
| Model | Claude Opus 4.7 (this session) | `openai/gpt-5.4-mini` via OpenRouter |
| Harness | Claude Code with Read/Edit/Bash tools | Plain Python loop, single OpenAI-compatible chat call per round |
| K | 10 (cap) | 10 (cap) |
| K used | **3** | **10** (exhausted) |
| Wall time | ~90 s | **51 s** |
| Result | **Success** (no sorry/admit/axiom) | **Failure** (10/10 attempts produced errors) |

## Strong trajectory (Claude Opus 4.7)

| Round | Outcome | Issue | Fix |
|------:|---------|-------|-----|
| 1 | 3 errors | Lean 3 sum syntax `∑ k in S` (deprecated in Mathlib4) | `in` → `∈` (mechanical) |
| 2 | 1 error | `simp_rw [heq]` made no progress because `harmonicSeq` appears un-applied in the goal | Lifted pointwise `heq` to function equality via `funext`, then plain `rw` (insight, not mechanical) |
| 3 | 0 errors | — | clean compile |

## Weak trajectory (gpt-5.4-mini)

| Attempt | n_errors | First error category |
|--------:|--------:|---------------------|
| 1 | 13 | Hallucinated `Function.eventually_within` (does not exist) |
| 2 | 2 | Type mismatch after simp |
| 3 | 3 | Type mismatch after simp (regressed) |
| 4 | **1** | Unsolved goals |
| 5 | 1 | `Finset.sum_Icc_succ_top` — wrong argument name |
| 6 | 1 | Type mismatch after simp |
| 7 | 1 | **`simp` made no progress** — same wall the strong agent hit at round 2 |
| 8 | 1 | Unsolved goals (induction step on `Icc 1 n` vs `range n`) |
| 9 | 1 | Same unsolved goals |
| 10 | 1 | Same unsolved goals |

## What gpt-5.4-mini got stuck on

After the initial cleanup (rounds 1–3), the model converged to 1 error and **stayed there for 7 rounds without ever closing the proof**.

**Notably, the weak model got the high-level strategy right** — its attempt 4 already had the correct overall shape:

```lean
intro h; rcases h with ⟨l, hl⟩
have hEq : harmonicSeq = fun n => ∑ x ∈ Finset.range n, (↑x + 1 : ℝ)⁻¹ := by funext n; ...
have h1 : Tendsto (...) atTop (nhds l) := ...
have h2 : Tendsto (...) atTop atTop := ... Real.tendsto_sum_range_one_div_nat_succ_atTop
exact not_tendsto_nhds_of_tendsto_atTop h2 l h1
```

This is **structurally the same plan I used**. The model knew:
- The right Mathlib lemma (`Real.tendsto_sum_range_one_div_nat_succ_atTop`).
- The `funext` insight to lift pointwise equality to function equality (the exact insight I needed at my round 2).
- The contradiction lemma (`not_tendsto_nhds_of_tendsto_atTop`).

What the weak model **could not close** is the *body of the bridge lemma* — the induction proving `harmonicSeq n = ∑ x ∈ Finset.range n, (x+1)⁻¹` for all `n`. The terminal goal at attempt 10 is:

```
case h.succ
ih : harmonicSeq n = ∑ x ∈ Finset.range n, (↑x + 1)⁻¹
⊢ ∑ x ∈ Finset.Icc 1 n, (↑x)⁻¹ = ∑ x ∈ Finset.range n, (↑x + 1)⁻¹
```

The model **unfolded `harmonicSeq` on the LHS prematurely** (turning `harmonicSeq n` into the Icc sum), so the IH (which mentions `harmonicSeq n` in unfolded-on-the-LHS-only form) no longer matches the goal syntactically and `rw [ih]` cannot fire. My proof avoided this by unfolding *before* the induction, so the IH and the goal speak the same language throughout.

This is a **proof-tactics-ordering** issue, not a strategy issue. The weak model lacks the meta-knowledge that "when doing induction with an unfolded definition, unfold it once before the induction so the IH is in matching form."

## Cost / time

- Strong: 3 LLM "rounds" + 3 lake compiles. ~90s wall. Free (this Claude Code session).
- Weak: 10 LLM rounds + 10 lake compiles. 51s wall. ~$0.0X (cheap; gpt-5.4-mini at OpenRouter list rate).

The weak run is **faster** in raw wall time because each call is small (~2s) and lake compile is constant-time on these short files. The strong run took longer per round only because of human-readable thinking time between rounds.

## Reading lens

This is a qualitative case study, not a statistical claim:

- **Mechanization (cheap diagnostic-fix loop) works fast and gets close.** From 13 errors to 1 in 4 attempts (~6 s of model time + compile time). The model can fix hallucinated lemma names, wrong sum syntax, type mismatches.
- **Strategy is also there, surprisingly.** The weak model independently produced the same high-level proof structure as the strong agent, including the `funext` insight that let me escape my round-2 wall.
- **The plateau is at proof-tactics ordering.** A K=10 diagnostic-fix loop cannot rescue a tactic-ordering bug whose fix is "unfold the definition once *before* the induction, not after each step." The diagnostic ("unsolved goals" with the IH and goal mismatch) tells the model *what* is wrong but not *how* to refactor the proof.
- This is the **specific shape of the gap a stronger model fills**: not strategic decomposition, but recognizing that two syntactic forms (`harmonicSeq n` vs the unfolded `∑ x ∈ Icc 1 n, ...`) need to be aligned for `rw [ih]` to fire.

The architectural takeaway: **diagnostic feedback alone is not a substitute for proof-restructuring capability**. A K-shot retry loop with a weak model converges to a local minimum it can't escape; the strong model is needed for the kind of refactor that requires reasoning *about the proof state* rather than reasoning *about the error message*.

## Files in this directory

- `attempt_{1..10}.lean` — exact Lean files the weak model produced.
- `attempt_{1..10}_raw.txt` — raw OpenAI chat completion text (pre-fence-strip).
- `attempt_{1..10}_diagnostics.json` — full lake compile output per attempt.
- `summary.json` — machine-readable trajectory.

Strong baseline lives one directory up at `manual_proofs/example-122-divergence-of-the-harmonic-sequence/proof.lean` (the verified Lean file) and `round_log.md` (the round-by-round narrative).
