# Final Presentation Design Document

## Core Gaps

**Gap 1: Verified ≠ Understood.** AI systems can now generate and verify formal proofs at scale, but verification does not imply understanding. A verified theorem tells us *what* is true — not *why*, not *when* the technique applies, not *what* a human should learn from it. As AI-generated proofs proliferate (AlphaProof, Lean copilots, etc.), the volume of verified-but-opaque results grows, and the gap between machine-verified and human-understood widens.

**Gap 2: Proof repair ≠ program repair.** Formalized math proofs are programs (in Lean, Coq, etc.), so proof repair shares surface similarities with program repair — the focus of this course. But proofs carry inherent mathematical complexity that standard programming repair tools cannot handle. A wrong proof is not just a "bug" in the usual sense.

---

## Deep Questions

### Q1: The three-layer problem — who decides what the model should reason about?

**The observation:** When humans do math, we make computational errors constantly — every college student knows the experience of botching arithmetic on an exam. Models exhibit the same fragility: if forced to compute long derivations via chain-of-thought (token-by-token reasoning), they frequently get things wrong. External tools (Lean, Mathematica, sympy) are reliable for computation but cannot do high-level strategy.

**The question:** We currently separate *strategy* (proof planning) from *mechanization* (Lean syntax/API). But there is a third layer — *intermediate computation and reasoning* — that sits in between. When a model needs to evaluate an integral, simplify an algebraic expression, or verify a numerical bound, should it reason through it in tokens, or delegate to a CAS? Right now, there is no principled control over this delegation. The model decides implicitly, and often decides poorly.

**Connection to our work:** Our case study already surfaces this. The 3 sorry's in the averaging proof ($\int_0^{2\pi} \max(\cos u, 0)\,du = 2$, etc.) are not strategy errors and not really mechanization errors — they are computations the model shouldn't be attempting in tokens at all. The proof skeleton implicitly identifies these as delegation candidates (they become sorry'd subgoals), but the delegation is not principled or automatic. This suggests a refined decomposition:

| Layer | What | Who should handle it | Failure mode if misassigned |
|-------|------|---------------------|-----------------------------|
| Strategy | Proof plan, decomposition | Powerful model | Dead-end approach, wasted effort |
| Computation | Algebraic manipulation, bounds, integrals | CAS / verified tools | Silent errors in CoT, false confidence |
| Mechanization | Lean syntax, API names, tactic plumbing | Cheap model + checker | Noisy but correctable compilation errors |

**Potential mitigation — "Reasoning Arbitration":** Rather than hoping the model delegates correctly on its own, we introduce a principled interception mechanism. The key design: **the model must state its computational objective before conducting any reasoning** (e.g., "I need to evaluate $\int_0^{2\pi} \max(\cos u, 0)\,du$" before attempting the computation in tokens). This objective declaration serves as an early signal that enables *proactive* arbitration:

1. The arbitrator detects the objective declaration in the token stream
2. Before the model generates a (potentially long, potentially wrong) CoT derivation, the arbitrator **pauses generation**
3. It routes the objective to the appropriate external solver (CAS, Lean checker, etc.)
4. The tool's verified result is injected back, and generation resumes with the correct answer already in context

This is fundamentally different from post-hoc checking (let the model finish, then verify). Proactive arbitration **saves the tokens entirely** — the model never generates the unreliable computation in the first place. The token budget is reclaimed for what the model is actually good at: strategy, planning, and high-level proof structure.

We call this **Reasoning Arbitration**: a principled mechanism that identifies reasoning that *shouldn't be done in tokens* and intercepts it before it happens, replacing it with rigid, tool-backed results.

**Why not just tool calling? — Who bears the routing complexity.** The natural objection: requiring the model to declare an objective is isomorphic to a tool call. Why not just give the model tools and let it call them? The answer is about *who bears the routing complexity*:

| | Tool calling | Reasoning Arbitration |
|---|---|---|
| **Who reasons?** | Main model | Main model |
| **Who routes?** | Main model (same context) | Dedicated arbitration agent (separate) |
| **Tool awareness** | Main model must hold all available tools in context | Main model sees no tools; arbitrator handles the full repertoire |
| **Scales to...** | ~10–20 well-defined tools (programming) | Hundreds of theorems, techniques, solvers (math) |
| **Failure mode** | Model is mid-reasoning AND choosing tools → cognitive overload, drops one or both | Each agent does one job well |

In programming, the tool list is small and cleanly separated — tool calling works fine. In mathematics, every theorem, lemma, and technique is potentially a "tool," and the selection problem is itself non-trivial (see Q4: Knowledge as Tools). Asking the main model to do complex mathematical reasoning *and* navigate a vast space of delegation targets in the same context degrades both tasks.

Reasoning Arbitration applies the same separation principle as our strategy/mechanization split, one level up:
- **Main model**: math reasoning, strategy, proof structure. Sees no tools. Just thinks.
- **Arbitration agent**: monitors, classifies, routes. Sees all tools but does no math. Its only job is: "what kind of computation is this, and who should handle it?"

This is why it's different from tool calling — not in mechanism, but in *architecture*. The routing decision is externalized to a specialist.

---

### Q2: Irreducible Knowledge Sets — what is the minimum a human needs to solve a problem?

**The idea:** For any problem, there exist *irreducible knowledge sets* — minimal collections of standard knowledge such that a person equipped with exactly that knowledge can solve the problem. This is not a single unique set; one problem can admit drastically different irreducible sets from different domains. The fundamental theorem of algebra can be proved via abstract algebra, complex analysis, or topology — each proof draws on a completely different minimal knowledge base. The irreducible knowledge set characterizes the *boundary* of a problem: it tells you what the problem truly requires, stripped of all redundancy.

**Why this matters for human learning:** This is essentially how textbooks are designed. An author selects a body of standard knowledge, then provides exercises that are solvable using exactly that knowledge. The reader learns not just the facts but *how to deploy them*. Knowledge alone is insufficient — having tools doesn't mean knowing which to pick up. The irreducible knowledge set serves as a guide: it tells you not just "what do you need to know" but "what is the shape of the problem in knowledge space."

**The human-model gap:** Humans understand *ignorance* — the acknowledgment that "I don't know this yet" is precisely what allows us to start from a clean foundation, acquire the missing piece, and build understanding. Language models lack this. They are pretrained on vast corpora and fine-tuned with RL, and the boundary between *parametric knowledge* (stored in weights) and *contextual knowledge* (derived during generation or provided in prompts) is blurred — both to us and to the model itself. Even if we instruct the model to reason only from provided premises, it may silently draw on memorized knowledge while presenting the appearance of fresh derivation. Our case study demonstrated this: the model "knew" the optimal $1/\pi$ bound from training data but acted as if it were deriving it from scratch.

**Connection to our work:** The digest agent's goal is essentially to recover something like an irreducible knowledge set from a proof trace — the reusable strategies and transferable insights that a human would need to solve similar problems. The non-uniqueness of irreducible sets maps directly to our knowledge graph structure: a single problem node can connect to multiple hub nodes (strategy templates), each representing a different irreducible path. The digest agent's four core functions (reinterpretation, scope expansion, progressive construction, strategy templates) are different lenses for identifying which knowledge sets a proof trace reveals.

The parametric/contextual knowledge confusion also poses a concrete evaluation challenge: if the model can't distinguish what it "already knew" from what it "figured out," how do we evaluate whether our system genuinely extracts learnable knowledge versus merely re-surfacing memorized associations? This connects back to the data leakage concern from our midterm results.

---

### Q3: Atomic step annotation — what makes a proof step *teachable*?

**The idea:** When solving a problem, we produce a sequence of steps. But the steps alone don't teach — what teaches is the *annotation* of each step: the intuition behind it, the related problems that share the same intuition, the abstract pattern it instantiates, and how it traces back to some irreducible knowledge. Textbooks generally don't do this. Solution manuals write steps and leave the reader to internalize patterns through practice. But if we want knowledge to be *explicitly transferable* rather than implicitly absorbed, each atomic step needs a structured annotation.

**Pikachu345's formalization (from Bilibili):** A solution is fully "analyzed" at the atomic level if it meets three criteria:

1. **Correctness:** It delivers a fully correct solution.
2. **Motivated steps:** For every step, we can explain *why* this step — the motivation, the intuition. And we can point to a *sibling problem*: a strongly related question where the same motivation applies.
3. **Feasibility boundary:** For each motivation/technique, we specify *when* it applies, *when* it's effective, and *when it fails*. For the failure case, we provide a *counterexample problem* — one where attempting this technique leads to a dead end — and point to what alternative method should be used instead.

This is a precise formalization of what it means to fully *understand* a solution, not just *have* one.

**The key challenge — abstraction level:** The annotation must hit the right level of abstraction. Too detailed and it's just restating the proof in words. Too abstract and it's vacuous ("use algebraic manipulation"). The sweet spot is the level where the pattern is recognizable across problems but concrete enough to act on. Finding this level automatically is hard — humans develop it through experience, and even among human educators, the quality of step-level annotation varies enormously.

**What's missing in the auto-theorem-proving community:** Current work in autoformalization and AI theorem proving optimizes for one thing: *did the proof compile?* (pass@k). There is essentially no work on annotating *why* each step was chosen, what its feasibility boundary is, or how it connects to steps in other proofs. The proving trace is treated as disposable scaffolding — once the proof compiles, the trace is discarded. This means:

- No sibling problems are identified (criterion 2 is entirely absent)
- No feasibility boundaries are characterized (criterion 3 is absent)
- Motivation is at best implicit in comments or variable names

The community produces verified proofs but not *teachable* proofs. This is exactly Gap 1 (verified ≠ understood) made concrete at the step level.

**Connection to our work:** Our digest agent's four core functions map partially onto this formalization:

| Pikachu345 criterion | Digest agent function | Coverage |
|---|---|---|
| Motivated steps + sibling problems | Reinterpretation, Scope expansion | Partial — we identify related problems but don't yet annotate per-step |
| Feasibility boundary | Strategy templates | Partial — templates capture "when to apply" but not "when it fails" |
| Counterexample problems (failure cases) | *Not currently addressed* | Gap |

The gap is clear: our digest agent works at the *proof level* (what strategy did this proof use?) but not at the *step level* (why this step, what's its boundary, what's the sibling problem?). Moving from proof-level to step-level annotation — and especially characterizing failure boundaries with counterexample problems — would be a significant deepening of System 2. The proving trace already contains the raw material (each Lean checker call is roughly a "step"), but we don't yet extract per-step teachable structure from it.

---

### Q4: Open sub-questions — the hard infrastructure problems

Several smaller but fundamental questions emerge from Q1–Q3. These are not yet answerable but define the research frontier our work is approaching.

**Quantifying shared intuition.** If two proof steps or two problems "share a common intuition," how do we measure that? Semantic similarity of natural language descriptions? Structural similarity of proof terms? Shared position in a knowledge graph? Our current approach uses hub-node co-membership in the knowledge graph as a proxy (two problems share an intuition if they connect to the same hub), but this is coarse. A finer-grained similarity metric — one that operates at the step level, not the problem level — is needed to make Q3's sibling-problem identification automatic.

**Proper abstraction of intuition.** What is the right *representation* of an intuition? A natural language sentence? A proof pattern with holes? A subgraph in the knowledge graph? Too concrete and it doesn't transfer; too abstract and it's vacuous. This is the same abstraction-level challenge from Q3, but framed as a representation problem. Our strategy templates are one attempt, but we don't yet have a principled answer.

**Human-collected vs. AI-bootstrapped.** Should these intuition structures be curated from human learning processes (like our Obsidian knowledge graph), or can AI bootstrap them once it reaches a certain capability level? The honest answer may be *both*: human-curated seeds to establish the right abstraction level, then AI expansion to scale. Our project sits at this boundary — the knowledge graph is human-authored, the digest agent attempts to recover its structure automatically.

**Constraining model knowledge.** Can we force a model to solve a problem *without* using certain knowledge — to simulate the experience of a learner who hasn't seen technique X yet? This would enable genuine evaluation of irreducible knowledge sets (Q2): give the model only knowledge set K, see if it can solve problem P. Current models make this nearly impossible due to the parametric/contextual boundary being opaque. Potential approaches: fine-tuning on restricted corpora, careful prompt engineering with verification, or using weaker models as proxies for "less knowledgeable" solvers.

**Exposing internal process.** Current model outputs are polished final answers. The actual internal process — where the model considered alternatives, hit dead ends, backtracked, and re-planned — is largely hidden (or at best, superficially narrated in CoT). But this process data is precisely what's most valuable, both for training other AI systems and for teaching humans. Our structured prover partially addresses this: the plan-implement-replan loop with explicit sorry skeletons makes the *proving* process visible. But the *reasoning* process within each planning step is still opaque. Making this visible — not just what the model did, but what it considered and rejected — is an open challenge.

**Knowledge as tools — can we apply knowledge via tool calling?** If we extract knowledge atoms, the natural instinct is to make them callable — wrap each technique as a "tool" the model can invoke. But this hits a fundamental mismatch. Tool calling in LLMs assumes: (a) a manageable number of tools, (b) clean separation between them, (c) well-defined input/output interfaces. Mathematical knowledge is messier than that. Consider integration: changing variable, changing integration order, integration by parts — each is a "technique," but applying integration by parts requires *identifying the right partition into parts*, which is itself a non-trivial reasoning step that doesn't fit a clean tool interface. And at scale, the "toolbox" becomes enormous — hundreds of theorems, lemmas, and techniques — far beyond what current tool-calling mechanisms handle well. This is the same problem humans face: having many theorems and not knowing which to use. Skills/tools work when the selection problem is easy; mathematical knowledge is precisely the domain where selection is the hard part. How knowledge atoms should be *applied* — not just extracted — remains an open question. Perhaps not as tools, but as something more like heuristic guidance or retrieval-augmented context?

**Connection to our work:** These questions collectively point to a deeper version of our project's thesis. We started with "extract knowledge from proof traces." These questions push toward: *what kind of knowledge, at what granularity, in what representation, for whom, and how do we know it's genuine?* Our current system is a first step; these questions define what a mature version would need to address.

---

## Scope and Contributions

### Deliverable 1: Reasoning Arbitration — principled reasoning delegation with external tools

The core idea (from Q1): separate what the model should *reason about* from what should be *computed by tools*, and build a principled delegation mechanism. This includes both the framework design and the tool integration as its implementation.

**Framework (the novel part):** Given a model's chain-of-thought or a proof skeleton's sorry'd subgoals, the system must:
1. **Detect** which steps are computation that shouldn't be done in tokens
2. **Route** each computation to the appropriate external tool
3. **Verify** by comparing tool output against CoT output, replacing when they diverge
4. **Reclaim** the token budget for what the model is actually good at: strategy and planning

**Tool integration (the engineering part):** The framework requires a heterogeneous toolbox — no single tool is universal:
- **sympy** (Python, open source) — symbolic math, integrals, algebra. Zero-friction starting point.
- **Wolfram Engine** (free for students / dev use, UIUC site license likely available) — full Mathematica kernel. Official MCP server exists. Upgrade path.
- **Google OR-Tools / Z3** — combinatorics, set problems, constraint satisfaction.
- **Lean checker** — type-level verification (already integrated).

This connects Q1 (three-layer separation), Q2 (irreducible knowledge — the tools are part of the "knowledge" available to the solver), and Q3 (atomic step annotation — the delegation decision itself is an annotatable step).

### Dataset curation — foundational contribution

**What:** Systematically curate the 455-note Obsidian knowledge graph into a formalized evaluation dataset. The raw material (human-authored notes with reasoning traces, 1596 bidirectional links) already exists. The curation pipeline:
1. AI-assisted extraction of individual problem statements from notes
2. Formalization as Lean 4 theorem statements (compilable with `sorry`)
3. Edge reconstruction at problem level (inherited from note-level links + within-note progression)
4. Node classification (problem nodes vs. technique/strategy nodes)

**Why this is a contribution:**
- The pipeline design itself — how to go from unstructured human knowledge to a formalized, graph-structured dataset — is methodology work.
- Quality metrics are a design space: edge faithfulness, formalization correctness, difficulty coverage, hub/leaf balance, domain diversity. Each metric choice is defensible and discussable.
- The resulting dataset is unique — no existing theorem-proving benchmark includes human reasoning traces and an explicit strategy graph. Standard benchmarks (miniF2F, ProofNet) have (problem, proof) pairs but no relational structure.
- It's the foundation that unlocks full-scale evaluation and digest agent improvement.

**One-day scope:** Curate a meaningful subset (30–50 notes), run the AI pipeline, produce statistics and sample formalizations, discuss metric design.

---

## Deliverables Summary (Post-Midterm)

| # | Deliverable | Type | Novelty |
|---|-------------|------|---------|
| 1 | Reasoning Arbitration — principled reasoning delegation + tool integration | Framework + engineering | High — novel delegation mechanism; tools are the implementation |
| 2 | Dataset curation pipeline + curated subset | Methodology + data | Medium — unique dataset with strategy graph |
| 3 | Digest agent redesign — atomic knowledge extraction | Framework + system design | High — grounded in a formal definition of what "learnable knowledge" means |

### Deliverable 3: Digest agent — from proof-level summaries to atomic knowledge extraction

**The problem with the midterm digest agent:** The original four core functions (reinterpretation, scope expansion, progressive construction, strategy templates) operate at the *proof level* — they ask "what strategy did this proof use?" But the discussion around Q2 and Q3 reveals this is too coarse. It doesn't tell a learner *why* each step was taken, *when* the technique applies, or *when it fails*. And our midterm evaluation (2/2 hub recovery vs 1/2) is weak because "relation" between problems was never precisely defined.

**Redesign grounded in knowledge atoms:** The digest agent should decompose a proof trace into **knowledge atoms** — the minimal transferable units of mathematical knowledge. Each atom is a 4-tuple:

| Component | What it captures | Example (Cauchy-Schwarz) |
|-----------|-----------------|--------------------------|
| **Trigger** | What does the subgoal look like when this applies? The "shape" you recognize. | "Two entangled quantities in a sum/product; need an upper bound" |
| **Action** | What do you do? The technique at the right abstraction — high-level, no low-level details. | "Separate via Cauchy-Schwarz inequality" |
| **Outcome** | What does it give you? | "A product of two independent norms — quantities decoupled" |
| **Boundary** | When does this fail despite matching the trigger? What's the alternative? | "Fails when the bound is too loose (lose the constant). Alternative: tighter inequality (AM-GM, Jensen) or restructure decomposition" |

Two uses of a technique in different proofs are the **same atom** if they share the same trigger and boundary. They're **different atoms** if the reason you reach for the technique and the way it can fail are fundamentally different.

**How this clarifies everything upstream:**
- **Irreducible knowledge set** (Q2) = minimal collection of atoms sufficient to solve a problem. Falls out naturally once you have the atoms.
- **"Relation" between problems** = shared atoms. Now precisely defined — two problems are related iff their irreducible knowledge sets overlap. Strength of relation = degree of overlap.
- **Hub node in knowledge graph** = an atom that appears in many problems' irreducible sets. High-degree hubs are the most transferable atoms.
- **Evaluation** = no longer vague "did we recover the right connections" but "did we recover the right atoms."

**The boundary problem:** The proof trace shows what *worked*, not what *fails*. The boundary component of each atom requires knowledge of problems where the technique doesn't work. This means the digest agent can't work from a single proof trace alone — it needs access to the knowledge graph (which contains negative examples and alternative approaches) or must be able to hypothesize boundaries and test them.

**Proposed evaluation — knowledge transfer to weak models:**
1. Strong model solves a problem → we have a proof trace
2. Digest agent decomposes into atoms (trigger, action, outcome, boundary)
3. Feed atoms as context to a weak model that *cannot* solve the problem on its own
4. If the weak model can now solve it → the atoms captured genuinely transferable knowledge

The weak model serves as a **controlled learner**: we know its baseline, the atoms are the only new information, so any performance gain is attributable to the knowledge transfer. This avoids the intractable "does it help humans" question by using a model as proxy.

**Open challenges:**
- Finding good strong/weak model pairs where the weak model's failure is *knowledge-based* (doesn't know the technique) not *capability-based* (can't follow instructions)
- Whether a digest agent can actually produce good boundary characterizations from proof traces alone
- The right abstraction level for atoms — too concrete and they don't transfer, too abstract and they're vacuous
- Knowledge application: atoms aren't cleanly callable as "tools" (see Q4: Knowledge as Tools), so how does a model *use* an atom it's been given?

### Class relevance — connecting to software repair

Reasoning Arbitration maps naturally onto auto-repair concepts from the course:
- **Fault localization** → detecting which part of the CoT is unreliable computation
- **Patch generation** → replacing faulty CoT with tool-verified results
- **Patch validation** → comparing tool output against CoT output to confirm divergence
- **Regression testing** → verifying the overall proof still holds after substitution

This framing makes our project a direct application of program repair ideas to a new domain (mathematical reasoning traces), not a tangential theorem-proving project.

---

## Implementation Plan

### Guiding Principles

1. **Start simple, then scale.** Validate every component on a small subset (2-3 problems, 10-20 notes) before running at full scale. The 455-node run happens only after the workflow is validated.
2. **Start with sympy, extend later.** sympy first, Wolfram/OR-Tools later. Each extension is incremental, not a redesign.
3. **Leverage AI tools aggressively.** Claude Code for local scripting, Codex for private content processing, ChatGPT for prompt iteration. 12 hours with AI tooling covers a lot of ground.
4. **The digest agent is the hardest part.** It depends on a successful proof run, requires non-trivial step decomposition, and models will fabricate atomic analyses if not properly guided. Invest the most design effort here.

### Phase 1: Infrastructure (parallel, ~1 hr total)

**1a. Metadata extractor (Claude Code builds this)**
- Parse all 455 notes: extract tags from YAML frontmatter, `[[wiki-links]]`, heading structure
- Build adjacency graph from wiki-links
- Compute degree distribution, identify hub nodes (degree ≥ 10)
- Output: `metadata.json` + graph statistics
- Validate: spot-check 10-20 nodes against the vault manually

**1b. sympy verification tool**
- Python module wrapping sympy: takes a mathematical claim (equation, integral, bound) as string → parses → evaluates → returns verified result
- Wrap as MCP tool (same pattern as `lean_checker_server.py`)
- Validate: test on the 3 sorry'd computations from the case study (e.g., $\int_0^{2\pi} \max(\cos u, 0)\,du = 2$)

### Phase 2: Reasoning Arbitration (builds on 1b, ~1-2 hrs)

**2a. Post-hoc arbitrator (simple version)**
- Python script: takes model text output → scans for mathematical claims → extracts each → verifies with sympy → reports/substitutes
- Validate on 2-3 model outputs (ask a model to solve problems via pure CoT, then run the arbitrator)

**2b. Three-tier ablation**
- Pick 5-10 math problems of varying difficulty
- Tier 1: run each model (Opus, GPT-5.4, a cheap model) with pure CoT, no tools
- Tier 2: same models, tools available (sympy + Lean checker as MCP tools), standard tool-calling
- Tier 3: same models with pure CoT, then post-hoc Reasoning Arbitration agent checks and corrects
- Metrics: correctness, number of computational errors, errors caught/corrected
- Start with 2-3 problems × 1 model to validate the setup, then scale

**2c. Streaming interception (future, claim in presentation)**
- Describe the architecture: hook into streaming API, detect objective declarations, pause and delegate
- Not implemented now, but the post-hoc version demonstrates the concept

### Phase 3: Dataset Curation (builds on 1a, ~2-3 hrs)

**3a. Codex workflow for problem extraction (prepare prompt + script)**
- Design output schema: `{note_title, problems: [{statement, type, difficulty, tags}], classification: "problem"|"technique"}`
- Write Python script that Codex will execute: reads each note, extracts problems per the schema
- Include few-shot examples in the prompt (manually craft 3-5 from notes we know)
- Run on Codex with a 10-20 note subset first, validate output quality

**3b. Edge reconstruction**
- Using metadata graph (from 1a) + extracted problems (from 3a), rebuild edges at problem level
- Within-note: if a note contains problems A → B → C (progressive), add edges A→B, B→C
- Cross-note: inherit wiki-link edges at the problem level
- Validate: check 10-20 edges manually against the vault

**3c. Lean formalization (optional, scale later)**
- For extracted problems, generate Lean 4 theorem statements with `sorry`
- Use Claude Code or Codex to generate, then run `lake env lean` to verify compilation
- Start with 5-10 problems, validate before scaling
- Formalization accuracy may be imperfect — document error rate, refine prompt

### Phase 4: Digest Agent Redesign (hardest part, ~3-4 hrs)

**4a. Bootstrap atomic analysis examples from the vault**
- Key insight: the Obsidian notes already contain human-authored explanations — motivations, connections, intuitions
- Workflow:
  1. Take a problem, feed only the *solution* to a model (not the full note)
  2. Model produces a proof/solution
  3. Compare the model's solution against the original note's explanations
  4. Where they match (same technique, same step), manually craft a few atomic analysis examples using the 4-tuple format
  5. These become few-shot examples that teach the model what atomic analysis looks like
- Start with 3-5 problems to build the example set

**4b. Digest agent prompt design**
- Using the few-shot examples from 4a, design a prompt that instructs the model to:
  1. Decompose a solution into steps
  2. For each step, produce a knowledge atom: (trigger, action, outcome, boundary)
  3. Identify the irreducible knowledge set (collection of atoms used)
  4. Flag where boundary information is uncertain (since the proof trace only shows what worked)
- Iterate the prompt on 2-3 problems, refine until output quality is acceptable

**4c. Run digest on case study**
- Run the redesigned digest agent on the complex subset sum proof traces (both quadrant and averaging methods)
- Compare: old digest (proof-level summary) vs new digest (knowledge atoms)
- Qualitative assessment: are the atoms meaningful? Do they match the human-authored knowledge graph connections?

**4d. Weak-model transfer test**
- Pick 2-3 problems where a weak model fails
- Extract atoms from strong model's solution using the digest agent
- Feed atoms to the weak model as context
- Does performance improve?
- Start with 1 problem to validate the experimental design, then scale

### Phase 5: Full-Scale Runs (after validation, scales naturally)

Once all components are validated on small subsets:
- Run Codex on all 455 notes → full curated dataset
- Run Reasoning Arbitration ablation on a larger problem set (20-50 problems)
- Run digest agent on more proof traces
- Run weak-model transfer on more problems
- Generate final statistics and figures for presentation/report

### Dependency Graph

```
Phase 1a (metadata) ──→ Phase 3 (curation) ──→ Phase 5 (full scale)
Phase 1b (sympy)   ──→ Phase 2 (arbitration) ──→ Phase 5
                                                  ↑
Phase 4 (digest) ─────────────────────────────────┘
```

Phase 1a, 1b, and 4a can all start in parallel. Phase 4 is the critical path — it takes the longest and has the most uncertainty.
