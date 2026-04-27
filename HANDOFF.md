# Handoff Document — CS598LMZ Final Presentation

**Date:** 2026-04-26
**Context:** Final presentation is tomorrow. This document enables any agent to pick up where we left off.

---

## Project Overview

CS598LMZ course project: structured AI theorem proving with knowledge extraction in Lean 4. Two-system architecture:
- **System 1 (Prover):** Plan-implement-replan loop for formal proofs
- **System 2 (Digest):** Extracts human-learnable knowledge from proof traces

After midterm, we developed three new conceptual contributions through deep discussion (captured in `/workspace/final-presentation/final-design.md`). The implementation lives in `/workspace/final-artifacts/`.

## Three Post-Midterm Deliverables

### Deliverable 1: Reasoning Arbitration
**Concept:** A dedicated agent that detects unreliable math computation in model CoT output and replaces it with tool-verified results (sympy). The key insight: "who bears the routing complexity?" — a separate arbitration agent handles routing so the main model can focus on reasoning.

**Files built:**
- `final-artifacts/scripts/sympy_verifier.py` — Verification engine. Handles integrals, equalities, inequalities, limits, series. **TESTED: 5/5 pass.**
- `final-artifacts/scripts/reasoning_arbitrator.py` — Post-hoc CoT scanner. Extracts math claims from text, verifies with sympy. **TESTED on case study trace: found 8 claims, verified 3 correct, 5 unparseable (markdown noise).**
- `final-artifacts/scripts/three_tier_eval.py` — Three-tier evaluation framework. 5 built-in problems. **BUILT, NOT YET RUN (needs API key).**

**What's left:**
- Run `three_tier_eval.py` with API key: `python3 final-artifacts/scripts/three_tier_eval.py --problems integral_max_cos series_basel --tiers 1 2 3`
- This produces the comparison table (Tier 1 pure CoT vs Tier 2 naive tools vs Tier 3 arbitration)
- The claim extraction regex is fragile on markdown — works better on clean model CoT output

### Deliverable 2: Dataset Curation
**Concept:** Turn the 455-note Obsidian vault into a structured evaluation dataset with a graph of mathematical relationships.

**Files built:**
- `final-artifacts/scripts/vault_metadata.py` — Metadata extractor. **RUN COMPLETE: 455 notes, 1510 edges, 33 hubs, 34 tags.**
- `final-artifacts/data/vault_metadata.json` — Full metadata for all 455 notes.
- `final-artifacts/data/vault_edges.json` — All 1510 edges.
- `final-artifacts/scripts/prepare_codex_batch.py` — Codex extraction pipeline. **DRY RUN DONE: 19-note Borel-Cantelli subgraph selected, task prompts prepared at `data/codex_extraction/`.**
- `final-artifacts/scripts/edge_reconstruction.py` — Problem-level edge builder. **BUILT, waiting on Codex extraction results.**

**What's left:**
- Run Codex extraction: `python3 final-artifacts/scripts/prepare_codex_batch.py --run --limit 5` (start with 5, then scale)
- Run edge reconstruction after Codex results arrive
- Optional: Lean formalization of extracted problems (requires working Mathlib — see Environment section)

### Deliverable 3: Digest Agent Redesign (Knowledge Atoms)
**Concept:** Redesign the digest agent to extract structured "knowledge atoms" — 4-tuples of (trigger, action, outcome, boundary) — instead of proof-level summaries. Grounded in Pikachu345's formalization of atomic analysis.

**Files built:**
- `final-artifacts/fewshot/atoms_examples.json` — 4 hand-crafted few-shot examples (complex subset sum + Borel-Cantelli).
- `final-artifacts/scripts/prompt_template_atoms.txt` — Full extraction prompt with few-shot examples, anti-hallucination guard, irreducible knowledge set request.
- `final-artifacts/scripts/digest_atoms.py` — Updated digest agent. **DRY RUN VERIFIED: prompt is 17K chars.**
- `final-artifacts/scripts/transfer_test.py` — Weak-model transfer experiment. **DRY RUN VERIFIED.**

**What's left:**
- Run digest on case study: `python3 final-artifacts/scripts/digest_atoms.py --trace workspace/traces/complex_subset_sum_reasoning.md`
- Run digest on proving trace: `python3 final-artifacts/scripts/digest_atoms.py --trace workspace/traces/complex_subset_sum_proving_trace.md`
- Run transfer test: `python3 final-artifacts/scripts/transfer_test.py --weak-model claude-haiku-4-5-20251001`
- Compare old digest (from `scripts/digest.py`) vs new atom-based digest

---

## Environment Status

### What works:
- Python 3.13 with sympy, anthropic, openai, matplotlib, numpy installed
- Lean v4.29.0-rc8 at `~/.elan/toolchains/leanprover--lean4---v4.29.0-rc8/`
- Lean v4.30.0-rc2 at `~/.elan/toolchains/leanprover--lean4---v4.30.0-rc2/`
- elan installed at `~/.elan/bin/` (add to PATH: `export PATH="$HOME/.elan/bin:$PATH"`)
- Codex CLI v0.117.0 available

### What doesn't work yet:
- **Mathlib precompiled oleans** — `lake exe cache get` fails because `lakecache.blob.core.windows.net` is blocked by the dev container firewall
- **Firewall** — The devcontainer runs `/usr/local/bin/init-firewall.sh` on start, which blocks most external domains. We changed `postStartCommand` in `.devcontainer/devcontainer.json` to disable it, but the change requires a container rebuild to take effect.
- After rebuild, run: `cd /workspace/docker && export PATH="$HOME/.elan/bin:$PATH" && lake exe cache get` to download Mathlib

### After container rebuild:
1. elan will need to be reinstalled: `curl -sSf https://raw.githubusercontent.com/leanprover/elan/master/elan-init.sh | sh -s -- -y --default-toolchain none`
2. Lean toolchains will need to be re-unpacked from the tarballs (still in `/workspace/`):
   ```bash
   mkdir -p ~/.elan/toolchains/leanprover--lean4---v4.29.0-rc8
   tar --zstd -xf /workspace/lean-4.29.0-rc8-linux.tar.zst -C ~/.elan/toolchains/leanprover--lean4---v4.29.0-rc8 --strip-components=1
   mkdir -p ~/.elan/toolchains/leanprover--lean4---v4.30.0-rc2
   tar --zstd -xf /workspace/lean-4.30.0-rc2-linux.tar.zst -C ~/.elan/toolchains/leanprover--lean4---v4.30.0-rc2 --strip-components=1
   ```
3. Python deps: `pip install sympy anthropic openai matplotlib numpy`
4. Then `lake exe cache get` should work (firewall disabled)

---

## Key Design Documents

- `/workspace/final-presentation/final-design.md` — **READ THIS FIRST.** Contains the deep questions (Q1-Q4), conceptual framework (Reasoning Arbitration, knowledge atoms, irreducible knowledge sets), deliverable definitions, evaluation design, and implementation principles.
- `/workspace/CLAUDE.md` — Project overview, architecture, common commands.
- `/workspace/midterm-report/` — Midterm report (LaTeX + PDF).
- `/workspace/our_solution.md` — Original two-system architecture design.

## Existing Artifacts to Reuse

- `/workspace/scripts/graph_analysis.py` — Original vault parser (PNG output). Metadata extractor reuses its patterns.
- `/workspace/scripts/digest.py` — Original digest agent (proof-level). Compare against new atom-based version.
- `/workspace/scripts/prompt_template.txt` — Old prompt. New one is at `final-artifacts/scripts/prompt_template_atoms.txt`.
- `/workspace/mcp_server/lean_checker_server.py` — MCP tool pattern (FastMCP).
- `/workspace/workspace/traces/complex_subset_sum_reasoning.md` — Reasoning trace (10K chars). Primary test input.
- `/workspace/workspace/traces/complex_subset_sum_proving_trace.md` — Proving trace (36 Lean checker calls).
- `/workspace/workspace/proofs/02a_complex_subset_sum_quarter.lean` — Fully verified proof.
- `/workspace/workspace/proofs/02b_complex_subset_sum_pi.lean` — 3 sorry's in analytic core.
- `/workspace/math-notes/笔记共享vault/math/` — 455 Obsidian notes (Chinese, private content).

## Implementation Principles (from the user)

1. **Start simple, validate on subset, then scale.** Test on 2-3 examples before running full scale.
2. **Start with sympy, extend to Wolfram later.**
3. **Digest agent is the hardest part.** Models fabricate atoms if not guided with few-shot examples.
4. **Bootstrap few-shot from the vault.** Notes contain human explanations. Feed model only the solution, compare against note's explanations, craft examples from matches.
5. **Leverage AI tools aggressively.** Claude Code + Codex CLI.

## Presentation Strategy

The user's preferred narrative (NOT "here's incremental progress" but "here's what we learned"):
1. Midterm recap (brief)
2. Post-midterm insight: "We discovered the three-layer problem — strategy vs computation vs mechanization. Nobody controls what gets delegated."
3. Reasoning Arbitration: the new design + who bears the routing complexity
4. Knowledge atoms + digest redesign: the 4-tuple formalization
5. Current results: three-tier eval table + atom extraction demo + dataset curation stats
6. Future work: streaming interception, weak-model transfer, full-scale eval

Slides will take ~3 hours, done after implementation.

## Directory Structure

```
/workspace/final-artifacts/
├── scripts/
│   ├── vault_metadata.py          # DONE: metadata extractor
│   ├── sympy_verifier.py          # DONE: sympy verification module
│   ├── reasoning_arbitrator.py    # DONE: post-hoc CoT arbitrator
│   ├── three_tier_eval.py         # DONE: evaluation framework (needs API run)
│   ├── prepare_codex_batch.py     # DONE: Codex batch prep (needs --run)
│   ├── edge_reconstruction.py     # DONE: problem-level edges (needs Codex results)
│   ├── prompt_template_atoms.txt  # DONE: knowledge atom prompt
│   ├── digest_atoms.py            # DONE: updated digest agent (needs API run)
│   └── transfer_test.py           # DONE: weak-model transfer (needs API run)
├── fewshot/
│   └── atoms_examples.json        # DONE: 4 hand-crafted examples
├── data/
│   ├── vault_metadata.json        # DONE: 455 notes metadata
│   ├── vault_edges.json           # DONE: 1510 edges
│   └── codex_extraction/          # PREPARED: 19 task prompts ready
├── results/
│   ├── arbitration/               # Has case_study_report.json
│   ├── digests/                   # Empty (needs API run)
│   └── transfer/                  # Empty (needs API run)
└── figures/                       # Empty (needs results first)
```

## Results (2026-04-27)

### D1: Reasoning Arbitration — DONE
- **LLM-based claim extraction: 89% verifiable** (8/9) vs regex baseline 37% (3/8)
- **Three-tier eval complete (5 problems):**
  - T1 pure CoT had errors in 3/5 problems (integral_gaussian: 3 errors, inequality_pi: 1, series_alternating: 1)
  - T3 arbitration caught errors in 2/5 problems (inequality_pi: 1 caught, series_alternating: 1 caught)
  - integral_gaussian errors not re-caught due to Codex extraction non-determinism between runs
- Results: `results/arbitration/three_tier_results.json`, `results/arbitration/llm_case_study_report.json`

### D2: Dataset Curation — DONE
- 40-note multi-hub subgraph selected (逐项估计 in=54, 和的积分估计 in=48, 分段估计 in=30)
- **Codex extraction: 40/40 notes processed, 212 problems extracted, 18 domains**
- Problem graph: 212 problems, 175 within-note edges, 1620 cross-note edges, 13 technique edges
- Category balance: 43% problem, 32% theory, 16% technique, 8% example_collection
- Difficulty distribution: 55% medium, 24% easy, 21% hard
- Problem types: 75 examples, 68 theorems, 36 exercises, 16 definitions, 14 lemmas, 3 counterexamples
- **Graph visualizations: 3 figures** (degree_distribution_new.png, hub_fanout.png, subgraph_stats.png)
- **Lean formalization: 4/4 compile** (3 fully proved, 1 sorry'd Basel problem statement)
- Quality metrics: `results/curation_metrics.json`

### D3: Digest Agent — DONE
- **Reasoning trace: 18 atoms, all valid, 0 uncertain boundaries, IKS size 2**
- **Proving trace: 14 atoms, all valid, 0 uncertain boundaries, IKS size 4**
- **Gold set validation: 71% step recall** (5/7 matched), **89% boundary quality** (16/18 concrete)
- IKS hub recall: 1/3 (pigeonhole matched, averaging/projection missed in IKS summary)
- **Old vs new comparison:** old=9882 chars prose, new=18 structured 4-tuple atoms with explicit boundaries
- Results: `results/digests/` (JSON + markdown for both traces + old digest)

### All scripts use Codex CLI as primary LLM backend (no API key needed)
Shared utility: `final-artifacts/scripts/llm_call.py`

## Remaining Work

1. **Make slides** (~3 hrs) — all results are in
2. **Objective-declaration variant (Tier 3b)** — optional, demonstrates proactive arbitration
3. **IKS strong-model ablation** — optional, tests if atoms are load-bearing
