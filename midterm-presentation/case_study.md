# Case Study: Complex Subset Sum

## The Problem

Given n complex numbers with ∑‖zₖ‖ = 1, prove there exists a subset S such that ‖∑_S zₖ‖ ≥ c.

Three known bounds: c = 1/6 (sector method), c = 1/4 (quadrant method), c = 1/π (optimal, averaging method).

## What We Proved in Lean 4

| Proof | Bound | Lines | Sorry count | Status |
|-------|-------|-------|-------------|--------|
| Quadrant method | 1/4 | 99 | 0 | **Fully verified** |
| Averaging method | 1/π (optimal) | 107 | 3 | Algebraic structure verified, analytic core sorry'd |

## Proof Skeleton (1/π, averaging method)

The skeleton demonstrates our plan-implement workflow. Phase 1 validates the decomposition; Phase 2 fills in each subgoal.

```lean
-- Phase 1: Skeleton (sorry'd subgoals, compiles)

lemma integral_max_cos :                              -- sorry: computation
    ∫ u in (0)..(2*π), max (cos u) 0 = 2 := by sorry -- (CAS-solvable in 1 line)

lemma exists_ge_avg (h : ∫ f = C) :                  -- sorry: library gap
    ∃ x, f x ≥ C / (b - a) := by sorry               -- (mean value thm for integrals)

lemma averaging_argument (h : ∑ ‖zₖ‖ = 1) :          -- sorry: integration plumbing
    ∃ α, ∑_{k∈S_α} Re(zₖ·e^{-iα}) ≥ 1/π := by sorry -- (Fubini + above two)

-- Phase 2: Main theorem (no sorry, proved from subgoals)

theorem complex_subset_sum_pi (h : ∑ ‖zₖ‖ = 1) :
    ∃ S, ‖∑_{k∈S} zₖ‖ ≥ 1/π := by
  obtain ⟨α₀, hα₀⟩ := averaging_argument h
  exact ⟨S_{α₀}, le_trans hα₀ (norm_ge_projection ...)⟩   -- ✓ compiles
```

**Key point:** The skeleton is readable and teaches the proof structure. The full 107-line proof is a wall of tactic scripts. Sorry's mark exactly where the math is vs. where the plumbing is.

## The Three Sorry's: Why They're Hard for Lean, Trivial for CAS

| Sorry'd Lemma | What it says | Why it's sorry'd | Mathematica equivalent |
|---|---|---|---|
| `integral_max_cos` | ∫₀²π max(cos u, 0) du = 2 | Must split at zeros, prove cos sign on subintervals, apply FTC per piece | `Integrate[Max[Cos[u],0],{u,0,2Pi}]` → `2` |
| `exists_ge_avg` | Mean value theorem for integrals | Standard analysis, but requires connecting several Mathlib lemmas | Textbook one-liner |
| `averaging_argument` | ∃ direction with projection sum ≥ 1/π | Requires Fubini (swap ∑ and ∫), polar decomposition, substitution | Straightforward once the above two are available |

**Observation:** None are mathematically hard. All are mechanically hard. This is the mechanization bottleneck in action.

**Future work:** CAS integration (Mathematica/sympy) as a verification oracle for sorry'd computational lemmas. The CAS confirms the result is correct; the gap is formalization debt, not mathematical uncertainty.

## Checker Call Breakdown (from actual Claude Code conversation log)

We used Claude Opus 4.6 in Claude Code with a Lean 4 + Mathlib Docker container as the checker.

| Category | Checker calls |
|---|---|
| Proof 1 (quadrant, 1/4) | 9 |
| API search (`exact?`, `#check`) | 11 |
| Proof 2 (averaging, 1/π) | 16 |
| **Total** | **36** |

**The mathematical strategy was correct from the first attempt for both proofs. All 36 checker calls were mechanization work.**

### Error classification (all 36 calls):

| Error type | Count | Examples |
|---|---|---|
| Wrong Mathlib API name | ~11 | `Complex.norm_eq_abs` doesn't exist; correct: `Complex.abs_re_le_norm` |
| Predicate form mismatch | ~4 | `≥ 0` vs `0 ≤` causes unification failure |
| Tactic/expression rewriting | ~8 | `-(α·I)` needs rewrite to `(-α)·I` before Mathlib lemmas apply |
| API search (`exact?`, `#check`) | 11 | Finding correct lemma names in Mathlib |
| Successful compilation | 2 | Final proof 1 ✓, final proof 2 ✓ |

**Mathematical strategy errors: 0.**

### What this means for our architecture:

- 100% of errors could be handled by a mechanization agent (cheap model + Lean API knowledge)
- The strategy agent (powerful model) was needed exactly once per proof: to produce the correct skeleton
- 34 of 36 calls were wasted capacity if using a single powerful model for everything
- Separating strategy and mechanization would reduce powerful-model calls from 36 to ~2

## Human Reasoning vs. LLM Output

**What the human explored** (documented in `complex_subset_sum_reasoning.md`):
1. Strip surface: "complex numbers" → really 2D vectors and directional alignment
2. Simple cases: n=2 reveals the problem is about *selection*, not summation
3. Probe the bound: 1/6 = (1/3)(1/2) → the constant reverse-engineers the proof
4. Bound landscape: 1/6 (sectors) → 1/4 (quadrants) → 1/π (averaging)
5. Counterexample: uniform distribution on circle achieves exactly 1/π → bound is tight
6. Connections: pigeonhole on directions appears in exponential sums, Steinitz lemma, etc.

**What the LLM produced:**
- Recalled 1/π from training data (correct, but from memory, not reasoning)
- Generated one proof
- When asked for a lesson: "decompose by coordinate signs" — shallow, 2D-specific, misses the actual principle

**The gap:** The human explored a landscape and built transferable understanding. The LLM retrieved a result and produced a proof. The exploration process is where mathematical knowledge is built — and it's exactly what's absent from (problem, proof) training data.

## Shallow vs. Deep Lesson

| | LLM lesson | Human lesson |
|---|---|---|
| Content | "Decompose by coordinate signs" | "Project onto a direction; tradeoff between concentration and alignment" |
| Scope | Specific to 2D, specific to this proof | Generalizes to higher dimensions and other problems |
| Transferable? | No — fails in 3D, misses the underlying principle | Yes — applies to exponential sums, Steinitz lemma, etc. |
| Why the difference | Saw one proof, pattern-matched | Explored 1/6 → 1/4 → 1/π, understood why each works |

## Limitations and Next Steps

**Data leakage concern:** Opus 4.6 produced the correct skeleton on the first try for both proofs. But when we asked about the optimal bound, it immediately said "1/π" — from memory, not derivation. The correct skeleton may be recall, not reasoning.

**Even the best case is expensive:** Even with a memorized correct strategy, it still took 36 calls — all mechanization. This is the *best case*. The model already knew the answer and still burned 34 calls on API names and syntax.

**What happens without prior knowledge?** With a smaller model or a novel problem, we'd also get strategy errors — replanning, dead-end exploration, wrong decompositions. The mechanization overhead compounds on top of that. **Immediate next step: run with a small model via OpenCode to get this data.**

## Additional Observations

**1. The simpler proof is easier to formalize; the optimal proof requires harder mechanics.**
The quadrant proof (1/4) is simpler and was fully formalized in 9 calls. The averaging proof (1/π) is optimal but requires integration machinery (Fubini, FTC, splitting integrals at zeros) — 16 calls and still 3 sorry's. The 1/4 and 1/6 bounds can be proved using very similar sector/quadrant methods; the 1/π bound requires fundamentally different (and heavier) Lean formalization.

**2. Partial transfer motivates the knowledge database.**
Proof 2 reused API names discovered during proof 1 (`Complex.re_sum`, `Complex.abs_re_le_norm`, etc.), but still needed 16 calls because exp/integration machinery lives in a different part of Mathlib with different conventions. If we had a database of related proofs and their API discoveries, we could feed that context to the agent and avoid many mechanical errors. This is exactly why we need the digest system.

**3. API search is a separable cost.**
11 of 36 calls were pure `exact?`/`#check` lookups — finding the right Mathlib lemma name. A premise retrieval tool (like LeanDojo's ReProver) could potentially eliminate those entirely. That's 30% of total cost removable by tooling alone.

**4. Ground truth check available.**
The complex subset sum problem exists as a node in our evaluation knowledge graph. Its ground truth connections link to the probabilistic method hub and the pigeonhole principle hub — corresponding exactly to our two proof methods (averaging = probabilistic method, quadrant = pigeonhole-style). Next step: test whether the digest agent discovers these connections.

## Summary

This case study demonstrates three things:

1. **Mechanization dominates proving cost.** 100% of errors were mechanization (API names, syntax, predicate forms). Separating strategy from mechanization would save ~95% of powerful-model calls.

2. **Sorry as architecture works.** The skeleton validates proof structure before filling details. It's also more readable than the complete proof — the sorry's mark where the math is vs. where the plumbing is.

3. **LLM lessons are shallow.** Without exploration (bound landscape, counterexamples, connections), the LLM produces problem-specific summaries rather than transferable strategies. The digest agent's job is to close this gap.
