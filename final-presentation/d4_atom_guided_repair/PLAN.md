# D4 Plan v2: Atom-Guided Reasoning — Pilot Study (Codex-reviewed)

## Revisions from v1

Codex flagged seven concerns; this revision addresses each. Plus we discovered we don't have GPU/small-model access from this container, which forces a path choice.

| Codex critique | Resolution in v2 |
|----------------|------------------|
| Selection bias from screening = eval set | Pre-register a fixed candidate pool of 8 problems; report all screened outcomes |
| N=5 too noisy | Drop to N=3 problems × 3 seeds = 9 runs/condition (more replication) |
| Graph structure confounded with content similarity | Replace `Random` control with **matched-irrelevant-context** (length-matched filler from unrelated mathematical text) |
| Hub-only not clean | **Drop hub-only**. Add `oracle atom` control instead. |
| Distance ≥ 1 ≠ no leakage | Mandatory **manual leakage audit** on all retrieved atoms before scoring |
| Codex-as-judge noise | **Exact-answer scoring first**, judge only for ambiguous cases |
| Phase 1 (vLLM) likely consumes session | **No vLLM**: use Codex (GPT-5.4) as the model under test (see Path Decision below) |

## Path Decision

We CANNOT run a small open-source model from this container — no GPU, no vLLM, no APIs to Together/OpenRouter. The user's RTX is on the host.

Two paths:

**Path A:** User sets up vLLM + Qwen on host, exposes port 8000 → we use it.
- Pro: tests the original hypothesis (small model benefits from atoms)
- Con: high setup risk, may consume 1-2 hrs of the budget alone

**Path B:** Use Codex (GPT-5.4) as the model under test.
- Pro: no setup, immediate execution; cleaner experiment
- Con: changes the claim from "atoms help WEAKER models" to "atoms help even on hard problems where Codex baseline-fails"

**Recommended: Path B** as the default; if user gets vLLM working in parallel, we run Path A as a secondary experiment.

The Path B claim is still meaningful: showing that retrieval-augmented atoms help a *strong* model on its failure cases is direct evidence for transfer, just framed differently. And we avoid the time cliff.

## Hypothesis (revised)

**On problems where Codex baseline-fails**, retrieval of knowledge atoms from 1-hop graph neighbors improves success rate vs. (a) no atoms, (b) length-matched irrelevant context.

If 1-hop > matched-irrelevant > baseline, that's evidence the atom *content* helps, not just "extra context."

If 1-hop ≈ oracle atom, retrieval is recovering the essential signal — strong evidence the graph-based retrieval works.

## Experimental Conditions (4)

| ID | Name | Prompt content | Purpose |
|----|------|----------------|---------|
| C0 | Baseline | Just the problem | Reference |
| C1 | Matched irrelevant | Problem + length-matched non-mathematical (or unrelated mathematical) text | Controls for "any context helps" |
| C2 | 1-hop retrieved | Problem + atoms from graph neighbors (audited for leakage) | The treatment |
| C3 | Oracle atom | Problem + manually selected single most-relevant atom | Upper bound — tells us if retrieval is the bottleneck |

## Scope

- **3 problems** (selected from a pre-registered pool of 8)
- **4 conditions** per problem
- **3 seeds** per (problem, condition) → 36 runs total

## Success Criteria

Primary metric: **success rate per condition** (number of seeds where the model produced a correct answer, summed across problems).

Reportable outcomes:
- C2 > C1 ≥ C0: graph-retrieved atoms genuinely help
- C2 ≈ C0 < C3: retrieval misses the right atom; oracle atom is needed
- C2 ≈ C1: any context helps; graph structure isn't doing work
- All ≈ baseline: model can't use atoms regardless

Even null results are publishable as a pilot.

## Step-by-step Execution Plan

### Phase 1: Pre-register problem pool (~30 min)

Pick 8 candidate problems from the curated D2 dataset that:
- Have known answers we can check
- Have at least 2 graph-distance-1 neighbors with extracted atoms or notes available
- Are stated cleanly (don't require image interpretation)
- Span at least 2 different math domains

Save the pool as `problem_pool.json` BEFORE running anything else. This locks in pre-registration.

### Phase 2: Atom generation for the candidate neighborhood (~45 min)

For each of the 8 problems' 1-hop neighborhoods:
- Identify the neighbor nodes (using D2's graph)
- For neighbors that don't already have atoms generated, run digest_atoms.py on the note's solution (if available) or skip
- Save atoms in `artifacts/atoms_per_node/`

If we already have atoms for many nodes (from D3 work), reuse them.

### Phase 3: Baseline screening (~45 min)

- For each of the 8 candidates, run Codex baseline (C0) once
- Codex acts as the model under test
- Score: did it produce the right answer?
- **Report ALL 8 outcomes**, not just the 3 we pick. This kills selection-bias reporting.
- Pick the 3 that fail baseline → these are our test problems

If fewer than 3 fail, expand to harder problems from the dataset.

### Phase 4: Build matched-irrelevant control text (~15 min)

For each test problem, generate a length-matched chunk of unrelated text:
- Same approximate token length as the 1-hop atoms
- Pull from an unrelated math domain (e.g., if the problem is about series, use text about geometry)

Save in `artifacts/matched_irrelevant/`.

### Phase 5: Manual leakage audit (~30 min)

For each test problem (3 of them):
- Inspect retrieved 1-hop atoms
- Label each atom: `safe / suspicious / leaking`
- "Leaking" = atom contains the answer, the exact technique name, or near-paraphrase of the solution
- If an atom is labeled `leaking`, we have a choice: drop it (cleaner) or keep it (more conservative). For the pilot, drop leaking atoms and report this.

Save audit log in `artifacts/leakage_audit.json`.

### Phase 6: Build oracle atom (~15 min)

For each test problem, manually select the single atom from anywhere in our extracted atom store that should most help. This is the upper-bound condition.

### Phase 7: Run the experiment (~60 min)

For each (problem × condition × seed):
1. Build prompt: problem + (optionally) context per condition
2. Call Codex via `codex exec`
3. Save raw output

36 runs × ~20s each = ~12 min for the calls alone. Add buffer for retries → ~30-40 min.

Use deterministic seeds via Codex's API where possible; otherwise just call 3 times and treat the variance as the noise band.

### Phase 8: Score outputs (~30 min)

For each output:
- **Exact-match scoring first**: extract the model's final answer; compare to known correct answer with sympy if numeric.
- For ambiguous cases (proof rather than numeric answer), use Codex-as-judge with a tight rubric: "Does this output reach the correct answer/conclusion?"

Tally per condition.

### Phase 9: Analysis + writeup (~45 min)

- Build the 4×3 result table (conditions × problems), with per-cell counts of correct/incorrect across the 3 seeds
- Compute aggregate success rates
- Write 1-page summary: hypothesis, design, results, honest scope statement
- Per-problem qualitative analysis: which atoms helped, which didn't, with one or two illustrative excerpts

### Phase 10 (stretch): Path A integration

If the user gets vLLM + Qwen running:
- Re-run Phase 7 against the small model
- Compare: do atoms help the small model MORE than Codex? (Expected yes — bigger lift on weaker model)

## Time Budget (revised)

| Phase | Estimate | Cumulative |
|-------|----------|-----------|
| 1 — Problem pool | 30 min | 30 |
| 2 — Atom generation | 45 min | 75 |
| 3 — Baseline screening | 45 min | 120 |
| 4 — Matched irrelevant | 15 min | 135 |
| 5 — Leakage audit | 30 min | 165 |
| 6 — Oracle atoms | 15 min | 180 |
| 7 — Run experiment | 60 min | 240 |
| 8 — Scoring | 30 min | 270 |
| 9 — Analysis + writeup | 45 min | 315 |
| **Total** | **5h 15min** | |
| Buffer | 45 min | **6h** |

## Output Structure

```
final-presentation/d4_atom_guided_repair/
├── PLAN.md                       # this file
├── codex_review.txt              # Codex's review of v1
├── D4_RESULTS.md                 # final writeup
├── artifacts/
│   ├── problem_pool.json         # the pre-registered 8 candidates
│   ├── screening_results.json    # all 8 baseline outcomes (transparency)
│   ├── selected_problems.json    # the 3 chosen (failed baseline)
│   ├── atoms_per_node/           # per-node atom files
│   ├── matched_irrelevant/       # control text per problem
│   ├── oracle_atoms.json         # manually selected best atom per problem
│   ├── leakage_audit.json        # safe/suspicious/leaking labels
│   ├── prompts/                  # one per (problem × condition × seed)
│   ├── outputs/                  # one per (problem × condition × seed)
│   ├── judgments/                # scoring per output
│   ├── results_table.csv         # 4 × 3 with seed-counts
│   └── summary.json              # aggregate stats
└── scripts/
    ├── select_pool.py            # screen the 8 candidates
    ├── generate_atoms.py         # batch atom extraction for neighbors
    ├── retrieve_atoms.py         # graph-distance retrieval + scrubbing
    ├── leakage_audit.py          # interactive audit harness
    ├── run_experiment.py         # main loop
    └── score_outputs.py          # exact-match + judge fallback
```

## Honest Scope (going in)

- N=3 problems × 3 seeds is a pilot, not a paper. Frame results as "directional evidence."
- Codex (Path B) is a strong baseline; "atoms help Codex on its failure cases" is a different claim than "atoms help weaker models." Both are valid.
- Manual leakage audit is the single biggest defense against over-claiming.
- All 8 screened outcomes will be reported, not just the 3 selected — full transparency.
- Time-cap each phase. If Phase 3 produces fewer than 3 baseline failures, expand the candidate pool rather than weakening the criterion.

## Definition of Done

- All 8 baseline-screening results saved (not just the 3 used)
- 36 model runs completed and saved with raw inputs/outputs
- Scoring complete with method documented per cell
- Leakage audit complete with explicit labels
- 4×3 result table with aggregate stats
- 1-page writeup honest about scope and limitations
- Reproducibility: anyone with Codex CLI can re-run
