# Our Solution: Two-System Architecture for Lean 4 Theorem Proving

## Overview

We build a two-system architecture: a **prover** (System 1) that iteratively proves theorems in Lean 4 through a structured plan–implement–replan loop, and a **lesson agent** (System 2) that extracts human-interpretable, reusable knowledge from proving traces. Lessons feed back into the prover to improve future proving sessions.

```
Problem → System 1 (prove) → Trace → System 2 (extract lessons)
             ↑                                    │
             └──────── lessons fed back ──────────┘
```

## System 1: Prover

The prover has two types of agents:
- **Strategy agent** (powerful model): mathematical reasoning, proof planning, implementation
- **Mechanization agent** (cheap model + Lean checker): compilation, error classification, simple fixes

They collaborate in a three-phase loop.

### Phase 1: Plan

The strategy agent explores the problem, reasons about the approach, and produces a **proof skeleton** — a complete Lean file where the main theorem is proved assuming sorry'd subgoals.

```
Input:  theorem statement (with sorry)
Output: proof skeleton — main theorem proved, subgoals sorry'd
Check:  must compile (sorry warnings OK, no errors)
```

What this validates:
- The subgoal decomposition makes sense
- The types and signatures are correct
- The main proof actually follows from the claimed subgoals
- The overall strategy is structurally sound

Example (from our case study):
```lean
-- Sorry'd subgoals (claimed, not yet proved)
lemma integral_max_cos : ∫ u in (0:ℝ)..(2*π), max (cos u) 0 = 2 := by sorry
lemma exists_ge_avg : ... := by sorry
lemma averaging_argument : ... := by sorry

-- Main theorem: fully proved from the subgoals above
theorem complex_subset_sum_pi ... := by
  obtain ⟨α₀, hα₀⟩ := averaging_argument z h
  exact ⟨S₀, le_trans hα₀ (subset_norm_ge_sum_re z S₀ α₀)⟩
```

### Phase 2: Implement

For each sorry'd subgoal, the strategy agent writes a full proof (no sorry). The mechanization agent acts as a filter/fixer.

```
Strategy Agent
  │
  │  writes full proof for one subgoal
  ▼
Mechanization Agent
  │  run Lean checker
  │
  ├─ No errors → subgoal closed ✓
  │
  ├─ Simple error (wrong lemma name, syntax, type mismatch)?
  │    → fix it, rerun checker, iterate
  │    → return fixed proof ✓
  │
  └─ Hard error (can't fix after N tries)?
       → package: original code + error + what was tried + why it failed
       → return to Strategy Agent with structured feedback
       → Strategy Agent revises and resubmits
```

The strategy agent never sees raw compiler errors for simple issues. It only gets called back when the mechanization agent determines the problem is not a simple fix.

### Phase 3: Replan

When a subgoal fails repeatedly in Phase 2, the strategy agent receives structured feedback:
- Which subgoal failed
- What errors occurred
- What fixes were attempted
- Why they didn't work

The strategy agent can then:
- Adjust the failing subgoal's statement
- Restructure the decomposition
- Change the overall strategy

After replanning, it produces a **new skeleton with sorry** and runs the checker to verify the revised decomposition compiles. Then back to Phase 2.

```
┌──────────────────────────────────────┐
│  Phase 1: PLAN                       │
│  Explore → Skeleton with sorry       │
│  Check: compiles (sorry OK)          │
└──────────────┬───────────────────────┘
               │
               ▼
┌──────────────────────────────────────┐
│  Phase 2: IMPLEMENT (per subgoal)    │
│  Strategy writes proof (no sorry)    │
│  Mechanization: run, fix, iterate    │
│  Simple error → fix locally          │
│  Hard error → report to Strategy     │
└──────┬──────────────┬────────────────┘
       │              │
   all closed    subgoal stuck
       │              │
       ▼              ▼
     Done    ┌─────────────────────────┐
             │  Phase 3: REPLAN        │
             │  Receive feedback       │
             │  Revise decomposition   │
             │  New skeleton with sorry│
             │  Check: compiles        │
             └────────┬────────────────┘
                      │
                      ▼
               Back to Phase 2
```

### Why separate strategy and mechanization?

| Aspect | Strategy Agent | Mechanization Agent |
|--------|----------------|---------------------|
| What it does | Choose approach, decompose proof | Find right API, fix syntax |
| Error type | Dead-end strategy, wrong decomposition | Wrong lemma name, type mismatch |
| Model need | Strong reasoning, few calls | Fast search, many calls |

A powerful model should not waste reasoning capacity on whether the Mathlib lemma is called `Complex.norm_eq_abs` or `Complex.abs_re_le_norm`. The mechanization agent handles that. The strategy agent focuses on mathematical structure.

## System 2: Digest Agent

The digest agent takes proving traces and produces structured, human-interpretable knowledge. Unlike simple summarization (which tends to produce shallow, problem-specific descriptions), the digest agent performs four core functions that mirror how humans learn from solving a problem.

### Core Function 1: Reinterpretation

Reframe the given problem into its essential mathematical structure by stripping away domain-specific surface.

Example: The complex subset sum problem says "complex numbers." The digest agent identifies that this is really about 2D vectors and directional alignment — complex number notation is convenient but not essential. This reframing changes what tools and intuitions are relevant.

Why this matters: An LLM that takes the problem at face value might search for complex analysis techniques. The reinterpreted version points toward geometric and linear-algebraic approaches instead.

### Core Function 2: Scope Expansion

From the given problem, generate natural questions that deepen understanding beyond the stated goal. For an inequality like ≥ 1/6:
- Can we achieve a better bound? (→ yes, 1/4 via quadrants)
- What's the optimal bound? (→ 1/π via averaging)
- Can we construct a counterexample showing some bound is NOT achievable? (→ uniform distribution on circle gives ceiling of 1/π)
- What's a simplified special case? (→ n=2 reveals that selection, not summation, is the core task)
- What's the generalized version? (→ what about higher dimensions? weighted versions?)

The given problem is a starting point, not the endpoint. Solving 1/6 alone gives a proof. Exploring the full landscape gives understanding that transfers to other problems.

### Core Function 3: Progressive Construction

Start from the simplest non-trivial case, understand it completely, then identify what carries forward to the general case.

Example: For n=2, z₁ = 1/2, z₂ = -1/2 reveals that taking everything (sum = 0) is worse than selecting one element (sum = 1/2). This tells us the problem is about **selection** — a structural insight that persists for all n and guides the proof approach (we're looking for a good subset, not a good ordering or arrangement).

This is building understanding bottom-up: simple cases expose the core difficulty without the complexity of the general problem, and the properties discovered often persist as n grows.

### Core Function 4: Strategy Templates

After solving the problem, extract the high-level approaches and identify connections to other problems where similar strategies apply. These become reusable templates — analogous to design patterns in programming.

Example: The complex subset sum problem uses "projection onto a direction + partition by sign/sector." This same template appears in:
- Bounding exponential sums in number theory
- The Steinitz rearrangement lemma
- Finding diameters that maximize signed distance on circles

The template is: *when bounding the norm of a vector sum, project onto a well-chosen direction. The tradeoff is between concentration (how much total mass falls in your selected subset) and alignment (how well vectors in that subset agree in direction).*

Strategy templates are abstract enough to transfer across problems but specific enough to be actionable. Discovering connections between templates — for instance, that the sector approach and the quadrant approach are both special cases of projection — further deepens understanding.

### Storage: Two Levels

**Standalone digests** (markdown files in `workspace/digests/`): The full exploration output — reinterpretation, scope expansion, strategy templates, connections. These are the comprehensive knowledge artifacts.

**Lemma annotations**: Concise strategic context attached to specific lemmas. When a lemma is used in a proof, the digest agent records not just *what* it proves but *when to use it* and *what kind of problem it belongs to*.

Example:
```
Lemma: abs_re_le_norm
Type:  |z.re| ≤ ‖z‖
Digest: Used in bounding vector sum norms via coordinate
        decomposition. Part of the projection-onto-direction
        family. Applied in: subset sum bounds, exponential
        sum estimates.
```

During future proving sessions, retrieval surfaces both the lemma and its strategic context — like progressive disclosure in skills. The agent sees not just a matching type signature but a hint about the high-level approach the lemma belongs to.

### The Feedback Loop

```
Problem → System 1 (prove) → Trace → System 2 (digest)
             ↑                              │
             │         ┌────────────────────┤
             │         │                    │
             │    Lemma annotations    Standalone digests
             │    (strategic context   (full exploration,
             │     on specific lemmas)  strategy templates)
             │         │                    │
             └─────────┴────────────────────┘
                    fed back to prover
```

The prover in future sessions can:
- Retrieve lemmas with strategic context (knows not just what a lemma proves, but what kind of problem it's for)
- Read relevant digests before starting (avoids known dead-ends, applies proven strategies)
- Access strategy templates that suggest exploration directions the prover wouldn't generate on its own
