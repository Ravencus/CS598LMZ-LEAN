# Problem Statement

## Core Argument: Verified Proofs Are Not Understanding

A Lean-verified proof tells us a theorem is true. It does not tell us *why* it's true, *when* the technique applies, or *what* we should learn from it. Having a proof is not the same as understanding the mathematics.

This is not a hypothetical concern. The classification of finite simple groups was announced as complete around 2004. The proof spans tens of thousands of pages across hundreds of papers by over a hundred authors. The simplified textbook project (Gorenstein, Lyons, Solomon) has been ongoing for decades and is still not finished. Even when it is finished, how long will a graduate student spend to understand it? The proof exists, it is verified by the mathematical community's most authoritative experts, but human understanding lags far behind.

Now imagine an AI system produces a Lean-verified proof of a significant conjecture. The Lean compiler says ✓. But what has humanity actually learned? If the proof is 10,000 lines of tactic scripts that the compiler accepts, we have gained a truth but not understanding.

This concern extends beyond mathematics. Consider an AI agent that generates a high-performance GPU kernel for a certain type of attention mechanism — 10,000 lines of CUDA code. It runs 5x faster than the baseline. It's not unreadable, but a human engineer looking at it cannot extract "here's why this memory access pattern is better" or "here's the principle I should apply to my next kernel." The knowledge is locked inside an artifact that is correct but opaque. The engineer has a faster kernel but has not become a better engineer.

We don't want to simply hand everything to AI agents and accept whatever they produce. We don't want to surrender to that. We value the human in this entire scheme. If an AI system can generate proofs, we want those proofs — and the process of generating them — to actually **enhance human understanding of mathematics**. We want to know: what to avoid, why certain choices were made, what strategies transfer to other problems, and what the proof reveals about the structure of the problem.

## Highlighted Concerns

We identify a range of concerns with current LLM-based theorem proving systems. Within the scope of this class project, we highlight three as both important and actionable.

### Concern 1: Verified proofs do not enhance human understanding

As argued above, a verified proof is a correctness certificate, not a teaching tool. Current systems optimize for one metric — does the proof compile? — and discard everything else. The proving process (what was tried, what failed, what the exploration revealed) is thrown away. Only the final artifact survives.

This means:
- A student reading an AI-generated Lean proof learns less than a student who struggled through the proof themselves
- A researcher who receives an AI proof of their conjecture knows it's true but may not gain the insight needed for the next conjecture
- The mathematical community accumulates truths without accumulating understanding

We want a system where the proving process itself produces knowledge — not just the final proof.

### Concern 2: LLM-generated lessons are shallow

Even when explicitly asked to extract lessons from a proof, LLMs produce surface-level descriptions rather than deep principles.

In our case study, after proving the complex subset sum bound via quadrant decomposition, the LLM summarized the approach as: "When bounding the norm of a vector sum, decompose by coordinate signs." This is misleading:
- It's specific to 2D — the technique doesn't directly extend to higher dimensions
- "Coordinate signs" is a surface feature of one particular proof, not the underlying principle
- The actual insight is about **projection onto a direction** and the **tradeoff between concentration and alignment** — a principle that generalizes broadly

The LLM produced this shallow summary because it only saw one proof. A human who explored the full landscape — trying 3 sectors (gives 1/6), then 4 quadrants (gives 1/4), then continuous averaging (gives 1/π) — understands *why* the quadrant method works, *where* it breaks down, and *what* the general principle is. The LLM pattern-matched on the proof it generated; the human built understanding through exploration.

This is not just a presentation problem (the lesson is hard to read). The knowledge extraction itself is poor. The system doesn't know what's important because it never explored the alternatives.

### Concern 3: Mechanization and mathematical reasoning are conflated

Current LLM provers use a single model for everything: choosing the proof strategy, finding the right Mathlib lemma name, fixing syntax errors, and making deep mathematical decisions. This is inefficient.

In our case study, we observed that 100% of proving iterations were mechanization errors — wrong API names (`Complex.norm_eq_abs` doesn't exist), predicate form mismatches (`≥ 0` vs `0 ≤`), tactic scope issues. The mathematical strategy was settled before any Lean code was written and never revised.

A powerful reasoning model should not spend its capacity on whether Mathlib calls the lemma `Complex.norm_eq_abs` or `Complex.abs_re_le_norm`. That's a retrieval problem, not a reasoning problem. Conversely, a fast retrieval model should not be asked to decide whether to use the quadrant approach or the averaging approach — that requires genuine mathematical insight.

By conflating these two types of work, current systems waste expensive reasoning capacity on cheap tasks and waste iteration budget on errors that a specialized agent could fix in one pass.

## Additional Concerns

The following are valid concerns that motivate our design but are not the primary focus of this class project.

### Exploration is absent from training data

LLMs are trained on (problem, proof) pairs — the finished product. The exploration process is never recorded: trying a weaker bound first, asking "is 1/6 tight?", constructing counterexamples, sweeping parameters (what if 4 sectors instead of 3?), discovering connections to other problems.

These activities are where human mathematical understanding is built. But since they don't appear in training data, LLMs cannot learn to perform them. They go straight from problem to proof via pattern matching, skipping the exploration that would build transferable knowledge.

### Recall rather than derive

LLMs often appear to understand results they are actually recalling from training data. In our case study, when asked about the optimal bound for the complex subset sum problem, the LLM stated "the optimal is 1/π" — correctly, but from memory, not from reasoning through the landscape.

This is a fundamental limitation. When training data is sufficiently large, simple transformations or equivalent formulations of the same result may appear multiple times. The model retrieves rather than derives. It produces the right answer without the understanding that would come from working through the problem. And if the training data contains errors or the problem is a novel variant, retrieval fails silently.

### No knowledge accumulation across sessions

Each proving session starts from zero. The system has no memory of what strategies worked on similar problems, what dead-ends to avoid, or which lemmas were useful in what contexts. A human mathematician accumulates this knowledge over a career. Current LLM provers accumulate nothing — every session is independent.

### No error classification

Errors are treated as pass/fail signals. The system does not distinguish "this is a wrong lemma name" (fixable by search) from "this entire approach is mathematically wrong" (requires rethinking). This leads to wasteful retry patterns: the model might change its entire proof strategy when the only problem was a misspelled identifier, or it might keep patching syntax when the fundamental approach is a dead end.

### Context window waste

Mechanization errors (wrong API names, syntax fixes, type mismatches) consume context window space that should be reserved for mathematical reasoning. With small or moderate context windows, a single proving session can exhaust its budget on mechanization before making any mathematical progress. This is especially relevant when using smaller, cheaper models — precisely the case where efficiency matters most.
