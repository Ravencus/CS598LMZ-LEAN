# Evaluation

## Two Systems, Two Evaluations

We have two systems (prover + digest agent), each needs its own evaluation. A third evaluation tests them together.

---

## Evaluation 1: Proving Effectiveness (System 1)

**Question:** Does the structured workflow (plan-implement-replan + mechanization separation) outperform a free agent?

**Setup:**
- **Structured agent**: Our workflow encoded in SKILL.md — plan with sorry, implement per subgoal, mechanization agent filters/fixes compilation errors, replan on hard failures
- **Free agent**: Same model, same MCP tool, no workflow — just "prove this theorem in Lean 4"
- **Problem set**: 5+ problems ranging from trivial to medium difficulty

**Metrics:**
1. **Pass rate**: Does it produce a sorry-free proof?
2. **Iteration count**: How many LLM ↔ Lean checker rounds?
3. **Error breakdown** (per rejected iteration):
   - *Mechanization error*: wrong Mathlib API name, syntax issue, type mismatch, predicate form (`≥ 0` vs `0 ≤`), decidability — fixable by search/pattern, no mathematical insight needed
   - *Mathematical error*: wrong proof strategy, dead-end decomposition, missing insight — requires rethinking the approach

**What we expect to show:**
- The structured workflow has comparable or better pass rate
- Fewer total iterations (mechanization agent absorbs cheap errors)
- The error breakdown justifies the separation: if most errors are mechanization, a powerful reasoning model is wasting capacity on cheap problems

**Key evidence from case study:**
- Complex subset sum proving trace: 100% of failed iterations were mechanization errors (wrong lemma names, predicate mismatches, tactic scope). 0% were mathematical strategy errors.
- The mathematical strategy was settled before any Lean code was written and never revised
- This means every call back to a powerful model was wasted — a cheap model with Lean API knowledge could have resolved all failures

---

## Dataset Curation Pipeline

**Source:** A private, human-authored Obsidian knowledge base — 455 markdown notes with 1596 bidirectional links, written by a mathematician over the course of their problem-solving practice.

**Why this is valuable:** Unlike standard (problem, proof) datasets, this vault contains the human reasoning process: problem reinterpretation, connections to related problems, technique identification, and scope expansion (strengthening bounds, generalizing). The bidirectional links explicitly encode relationships that are normally implicit.

**Challenge: One note ≠ one problem.** A single note often contains multiple problems with a progression structure:
- An original question (e.g., someone asked the author a problem)
- Analysis and reinterpretation
- A strengthened version (better bound, weaker hypothesis)
- A generalization (higher dimensions, broader setting)
- Special cases that reveal structure

For example, a note on subset sums might contain: the 1/6 bound (original), the √2/8 bound (improved), the 1/π bound (optimal), and a d-dimensional generalization — four distinct problems with internal dependency.

**Curation pipeline:**

```
Raw Obsidian vault (455 notes, 1596 note-level edges)
        │
        ▼
Step 1: Problem extraction
        Extract individual problem statements from each note.
        One note → potentially multiple problems.
        │
        ▼
Step 2: Rebuild connections
        Note-level edges → problem-level edges.
        - Inherited edges: problems in note A link to problems in note B
          (from the original bidirectional links)
        - Internal edges: problems within the same note
          (strengthening, generalization, special case)
        │
        ▼
Step 3: Lean formalization
        Each extracted problem → Lean 4 theorem statement (with sorry)
        Verify compilation against Lean checker.
        │
        ▼
Step 4: Classification
        - Problem nodes: have a formalizable theorem statement
        - Technique nodes (hubs): no problem, pure strategy description
          → these become ground truth labels for evaluation
```

**Current status:** Graph structure parsed and analyzed. Problem extraction and formalization is the next data task.

**Graph statistics (from structural analysis):**

| Tier | In-degree | Count | % | Role |
|------|-----------|-------|---|------|
| Hub nodes | ≥ 10 | 34 | 7% | Strategy templates (ground truth labels) |
| Medium nodes | 3–9 | 131 | 29% | Reusable techniques |
| Leaf nodes | 1–2 | 314 | 55% | Individual problems (evaluation pool) |
| Isolated | 0 | 97 | 17% | Standalone notes |

Top hub nodes (strategy templates): term-by-term estimation (54 links), integral estimation of sums (48), segmented estimation (30), Borel-Cantelli applications (22), summation by parts (20).

The degree distribution follows a power law — a small number of high-level strategies connect to a large number of problems. This matches how mathematical knowledge is structured: many specific problems, few general principles.

---

## Evaluation 2: Knowledge Extraction Quality (System 2)

**Question:** Does the digest agent extract deep, transferable knowledge — or shallow summaries?

**Ground truth:** A private, human-authored Obsidian knowledge base of mathematical problem-solving notes.
- 455 problem/concept nodes
- 1596 bidirectional links (edges)
- Hub nodes are high-level strategy templates (e.g., "term-by-term estimation" linked from 54 problems, "integral estimation of sums" from 48)
- Each node contains the author's analysis: problem reinterpretation, technique identification, connections to related problems

**Setup:**
- Pick a problem node from the graph
- Run the digest agent on that problem (with its proof/trace)
- Check which ground truth edges the digest recovers

**Metric: Weighted edge recall**
- For each ground truth edge from the problem node, does the digest mention or imply the connected node?
- Weight by target node degree: recovering a connection to a hub strategy (degree 54) counts more than a connection to a leaf problem (degree 2)
- This naturally rewards finding high-level transferable strategies over shallow problem-specific similarities

**What this tests:**
- Can the agent identify *which* high-level strategy a problem uses? (problem → hub edges)
- Can the agent find *related problems* that share techniques? (problem → problem edges)
- Does it find the *right* connections, not just any connections? (precision)

**Baseline comparison:**
- Plain LLM: "Summarize the key ideas of this proof" — measure edge recall
- Digest agent with four core functions (reinterpretation, scope expansion, progressive construction, strategy templates) — measure edge recall
- If the structured digest recovers more edges, the four core functions add value beyond naive summarization

**Why hub nodes matter:**
- Hub nodes = reusable strategies that appear across many problems
- These are exactly what humans build up over a career of problem-solving
- A digest that identifies "this problem uses the probabilistic method (expectation argument)" is more valuable than "this problem bounds a sum"
- Degree-weighted scoring captures this: recovering the connection to the probabilistic method hub (linked from many problems) scores higher

**Matching challenge:**
- The digest won't use identical titles — it says "averaging argument" not "通过求期望证明具有某种性质的结构的存在性"
- For the midterm: manual inspection on a few examples suffices
- For full evaluation: semantic similarity matching between digest text and node titles/content

---

## Evaluation 3: Transfer (System 1 + System 2, future work)

**Question:** Does a digest from problem A improve proving on problem B?

**Setup:**
- Prove problem B *without* any prior digests — record pass rate, iterations, errors
- Prove problem B *with* the digest from a related problem A — record the same
- Compare

**What we expect:**
- With digests: fewer iterations, avoids known dead-ends, applies proven strategies
- The knowledge graph tells us which problems *should* help each other (they share edges)

**Status:** This is future work. The midterm demonstrates the machinery (digest agent + evaluation framework). Running it at scale is execution.

---

## Summary for slides

| Evaluation | System | Metric | Ground Truth |
|---|---|---|---|
| Proving effectiveness | System 1 (Prover) | Pass rate, iterations, error breakdown | Lean compiler (correctness), manual error classification |
| Knowledge extraction | System 2 (Digest) | Weighted edge recall | Human knowledge graph (455 nodes, 1596 edges) |
| Transfer | System 1 + 2 | Proving improvement with vs. without digests | Future work |
