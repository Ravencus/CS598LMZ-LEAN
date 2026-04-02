# Slide Plan — CS598LMZ Midterm Presentation

**Total: 11 slides, 8 minutes**

---

## Teammate 1: Problem Statement (2 min, 3 slides)

### Slide 1: Title
- Project title
- Team names
- Date

### Slide 2: Verified Proofs ≠ Understanding
- Core argument in 3 bullets:
  - Lean says ✓. But what has humanity learned?
  - 10,000 lines of tactic scripts = truth without understanding
  - We want proofs that enhance human understanding of mathematics
- One-line example: finite simple groups (proof exists, spans tens of thousands of pages, understanding lags decades behind)

### Slide 3: Three Concerns
- Three boxes, one sentence each:
  1. **Verified ≠ understanding**: Proving process (what was tried, what failed) is thrown away. Only the final artifact survives.
  2. **LLM lessons are shallow**: "Decompose by coordinate signs" — specific to 2D, misses the actual principle.
  3. **Mechanization ≠ reasoning**: 100% of proving iterations were API name errors, not mathematical errors. These are different problems needing different tools.

---

## Teammate 2: Solution Architecture (2 min, 3 slides)

### Slide 4: System 1 — Prover
- Plan-implement-replan diagram (ASCII or visual):
  ```
  Phase 1: Plan → skeleton with sorry (compiles)
  Phase 2: Implement → fill each subgoal (no sorry)
           Mechanization agent filters/fixes compilation errors
  Phase 3: Replan → if stuck, revise decomposition
  ```
- Small table:
  | | Strategy Agent | Mechanization Agent |
  |---|---|---|
  | Does | Choose approach, decompose | Fix syntax, find API names |
  | Model | Powerful, few calls | Cheap, many calls |

### Slide 5: System 2 — Digest Agent
- 2x2 grid, one line per function:
  | Reinterpretation | Scope Expansion |
  |---|---|
  | Strip surface, find essential structure | Generate natural follow-up questions |
  | **Progressive Construction** | **Strategy Templates** |
  | Start from simplest case, build up | Extract reusable patterns across problems |

### Slide 6: Feedback Loop
- Full architecture diagram:
  ```
  Problem → System 1 (prove) → Trace → System 2 (digest)
               ↑                              │
               └──── lessons fed back ────────┘
  ```
- Two-level storage: standalone digests + lemma annotations
- "Prover reads relevant digests before starting. Avoids known dead-ends."

---

## You: Evaluation + Case Study + Next Steps (4 min, 5 slides)

### Slide 7: Evaluation Dataset
- **Left**: Tier breakdown figure (pie chart + top hubs bar chart)
  - 455 nodes, 1596 edges
  - 34 hub nodes = strategy templates (ground truth)
  - 314 leaf nodes = problem pool
  - Power-law degree distribution
- **Right**: Data curation pipeline (vertical flow):
  ```
  Raw Obsidian vault (455 notes)
      ↓
  Extract problems (one note → multiple problems)
      ↓
  Formalize in Lean 4 (verify with compiler)
      ↓
  Rebuild edges (problem-level connections)
  ```
- Note: "One note may contain the original problem, a strengthened version, a generalization, and special cases"

### Slide 8: Evaluation Metrics
- Two-column layout:
- **Left column — System 1: Proving Effectiveness**
  - Structured workflow vs. free agent
  - Metrics:
    - Pass rate (sorry-free?)
    - Iteration count
    - Error breakdown: mechanization vs. mathematical
  - "If 90% of errors are mechanization, 90% of powerful-model calls are wasted"
- **Right column — System 2: Knowledge Extraction**
  - Weighted edge recall against knowledge graph
  - Given a problem, does the digest recover ground truth connections?
  - Weight by node degree: hub connections count more
  - Baseline: plain LLM summary vs. structured digest agent

### Slide 9: Case Study — Proving Results
- **Left**: Proof skeleton pseudocode (~15 lines)
  ```lean
  lemma integral_max_cos := by sorry     -- computation
  lemma exists_ge_avg := by sorry        -- library gap
  lemma averaging_argument := by sorry   -- plumbing

  theorem complex_subset_sum_pi := by    -- ✓ no sorry
    obtain ⟨α₀, hα₀⟩ := averaging_argument h
    exact ⟨S_{α₀}, ...⟩
  ```
- **Right**: Error breakdown table
  | Category | Calls |
  |---|---|
  | Proof 1 (quadrant, 1/4) | 9 |
  | API search (`exact?`) | 11 |
  | Proof 2 (averaging, 1/π) | 16 |
  | **Total** | **36** |
  | Mathematical errors | **0** |
- Bold takeaway: "Strategy correct on first attempt. All 36 calls were mechanization."

### Slide 10: Case Study — Knowledge Gap
- **Top row**: Shallow vs. deep lesson comparison
  | LLM lesson | Human lesson |
  |---|---|
  | "Decompose by coordinate signs" | "Project onto a direction; concentration vs. alignment tradeoff" |
  | Specific to 2D, not transferable | Generalizes to higher dimensions and other problems |
- **Bottom row**: Data leakage concern
  - "Model recalled 1/π from memory — correct, but not derived"
  - "Even with memorized strategy, 36 calls of mechanization overhead"
  - "What happens when the model doesn't know the answer?"
- **Key point**: "The exploration process (1/6 → 1/4 → 1/π) is where understanding is built. The LLM skipped it entirely."

### Slide 11: Next Steps
- Three bullets with timeline:
  1. **Small model via OpenCode** — Run the same problem with a smaller model. Get replanning data, compare error breakdown. (Immediate)
  2. **Digest agent evaluation** — Run digest on proving trace. Measure edge recall against the knowledge graph. Does it find the probabilistic method and pigeonhole connections? (Immediate)
  3. **CAS bridge** — Mathematica/sympy as verification oracle for sorry'd computational lemmas. `Integrate[Max[Cos[u],0],{u,0,2Pi}]` → `2` in one line. (Future)
- Closing line: "The machinery is built. Scaling to the full evaluation is execution."
