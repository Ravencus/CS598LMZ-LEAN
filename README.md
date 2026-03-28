# Lean 4 Theorem Proving System

Two-system architecture for interactive Lean 4 theorem proving with trace-based analysis.

## Architecture

```
┌──────────────── Docker Container ─────────────────┐
│                                                     │
│  Toolchain (baked into image):                     │
│    Lean 4.29.0-rc8 + Mathlib (precompiled)         │
│    OpenCode v1.3.3                                  │
│    Python 3.11 + MCP server runtime                │
│                                                     │
│  Workspace (mounted from host):                    │
│    User ←→ [OpenCode + Skills]                     │
│                 │ (MCP/stdio)                       │
│                 v                                   │
│           [MCP Server] → [Lean 4] → diagnostics   │
│                                                     │
│    [Digest Script] ← traces from OpenCode          │
│           │                                         │
│           v                                         │
│    digests/ (proof schemas + failure lessons)       │
└─────────────────────────────────────────────────────┘
```

**System 1 (Prover):** OpenCode coding agent with a Lean MCP tool. Takes a math problem, iteratively writes and checks Lean 4 proofs. A skill encodes a structured workflow: explore, plan, search lemmas, prove step-by-step.

**System 2 (Digest):** Analyzes proving session traces and extracts structured lessons — proof schemas (what worked) and failure lessons (what didn't and why).

## Components

### Lean MCP Server (`mcp_server/lean_checker_server.py`)

Exposes one tool: `check_lean_proof(code: str)`. Writes code to a scratch file in a Mathlib-enabled Lake project, runs `lake env lean`, returns structured diagnostics (line, column, severity, message).

### Proving Skill (`workspace/.opencode/skills/lean-prover/SKILL.md`)

Instructions for the proving agent, auto-loaded by OpenCode via progressive disclosure. Encodes a structured workflow rather than blind tactic guessing.

### Digest Script (`scripts/digest.py`)

Reads an exported OpenCode session trace (JSON), sends it to an LLM with a structured prompt, outputs a markdown digest.

## Quick Start

```bash
# 1. Clone the repo
git clone https://github.com/Ravencus/CS598LMZ-LEAN.git
cd CS598LMZ-LEAN

# 2. Pull the pre-built image (includes Lean 4, Mathlib, OpenCode, MCP server)
docker pull ghcr.io/ravencus/cs598lmz-lean:latest

# 3. Run interactively (mounts workspace for persistence)
docker run -it \
  -e OPENCODE_API_KEY=<your-opencode-zen-key> \
  -v $(pwd)/workspace:/home/lean/workspace \
  ghcr.io/ravencus/cs598lmz-lean:latest

# 4. Inside the container, start OpenCode
opencode
```

To get an OpenCode API key: sign up at https://opencode.ai and go to settings.

## Setup

### Option A: Pull pre-built image (recommended)

```bash
docker pull ghcr.io/ravencus/cs598lmz-lean:latest
```

### Option B: Build from source

```bash
docker build -t cs598lmz-lean .
```

### Run interactively

```bash
docker run -it \
  -e OPENCODE_API_KEY=<key> \
  -v $(pwd)/workspace:/home/lean/workspace \
  ghcr.io/ravencus/cs598lmz-lean:latest
```

Inside the container:
```bash
opencode
```

### Run a single proving task

```bash
docker run --rm \
  -e OPENCODE_API_KEY=<key> \
  -v $(pwd)/workspace:/home/lean/workspace \
  ghcr.io/ravencus/cs598lmz-lean:latest -c \
  'opencode run -m opencode/gpt-5-nano "Prove in Lean 4: ∀ n : Nat, n + 0 = n"'
```

### Export a session trace

```bash
# Inside the container after a session:
opencode session list
opencode export <session-id>
```

## Problems and Proofs

Problems are theorem statements (with `sorry`) in `workspace/problems/`. Proofs are in `workspace/proofs/`.

| # | Problem | Proof | Status |
|---|---------|-------|--------|
| 01 | `∀ n : Nat, n + 0 = n` | — | Statement only |
| 02 | `∃ S, ‖∑_S z‖ ≥ 1/6` (complex subset sum) | `02a` quadrant method (1/4 bound) | **Complete** (0 sorry) |
| 03 | `∃ S, ‖∑_S z‖ ≥ 1/π` (optimal bound) | `02b` averaging method | Structure complete (3 sorry in analytic core) |

Problem 02–03: Given n complex numbers with ∑|zₖ| = 1, prove a subset sums to large norm. The quadrant proof decomposes into Re/Im positive/negative parts. The averaging proof integrates over all directions — algebraic structure is verified, integration lemmas are sorry'd.

Hand-crafted traces in `workspace/traces/`:
- `complex_subset_sum_proving_trace.md` — Lean formalization trace (attempts, errors, revisions)
- `complex_subset_sum_reasoning.md` — mathematical reasoning trace (exploration strategies, bound landscape, human problem-solving patterns)

## Next Steps

### 1. Test OpenCode + SKILL.md integration

Verify that SKILL.md loads and guides the proving workflow inside the Docker container. Run on the problems in `workspace/problems/` (especially 02/03, the complex subset sum). Try with different models on OpenCode Zen.

```bash
docker run -it \
  -e OPENCODE_API_KEY=<key> \
  -v $(pwd)/workspace:/home/lean/workspace \
  ghcr.io/ravencus/cs598lmz-lean:latest
# Inside: opencode
# Then ask it to prove problem 02 or 03
```

After the session, export the trace:
```bash
opencode session list
opencode export <session-id>
```

This produces a real automated trace to compare against our hand-crafted ones.

### 2. Lesson agent: extract lessons from traces

The hand-crafted traces (`workspace/traces/`) were produced using Claude Code on the complex subset sum problem. The lesson agent should extract structured lessons from these traces. Two types of content to extract:

**Error classification:** Separate mechanization errors from mathematical errors.
- *Mechanization*: wrong Mathlib API names, predicate form mismatches (`≥ 0` vs `0 ≤`), missing `.symm`, decidability issues — fixable by knowing Lean/Mathlib conventions.
- *Mathematical*: wrong proof strategy, dead-end approach, missing insight — requires actual mathematical reasoning.

**Abstract lessons:** High-level strategies that transfer across problems, not surface-level summaries tied to one proof. For example, "decompose by coordinate signs" is a bad lesson (specific to 2D, misses the underlying principle). "Project onto a direction and bound the projection" is a better lesson (generalizes to higher dimensions and other problems).

Design prompts for `scripts/digest.py` that produce these two outputs from a trace. Test on the hand-crafted traces first, then on real OpenCode traces from step 1.

### 3. Use distilled lessons to enhance OpenCode proving

Take the lessons extracted in step 2 and feed them back to the OpenCode proving agent. Two approaches:

- **Via digests folder:** Place lesson files in `workspace/digests/`. The SKILL.md instructs the agent to check this folder before proving. The agent reads relevant lessons and avoids known dead-ends.
- **Via SKILL.md updates:** Incorporate general-purpose strategies (start from simple cases, probe the bound, classify errors) directly into the proving skill.

Test whether the OpenCode agent (with small models) performs better with distilled lessons than without. Compare: number of iterations, types of errors, whether known dead-ends are avoided.

### 4. (Future) Retrieval tools via MCP

Integrate retrieval systems as additional MCP tools for the proving agent:

- **Premise retrieval (LeanDojo/ReProver):** Given a proof state, find relevant Mathlib lemmas. Addresses the mechanization bottleneck — our proving trace shows that finding the right API name (`Complex.abs_re_le_norm` etc.) was the dominant cost.
- **Lesson retrieval:** Given a problem or proof state, retrieve relevant distilled lessons from the digests folder. Addresses the strategy bottleneck — avoid known dead-ends, apply proven strategies.

Both are retrieval problems that reduce proving iterations. One handles "what Lean tactic/lemma to use" (mechanization), the other handles "what proof strategy to try" (mathematics).

## File Structure

```
├── Dockerfile                          # Toolchain image (Lean, Mathlib, OpenCode, Python)
├── README.md
├── docker/
│   ├── lakefile.lean                   # Lake project config (Mathlib dependency)
│   └── lean-toolchain                  # Pins Lean version
├── mcp_server/
│   ├── lean_checker_server.py          # Lean checker MCP server
│   └── requirements.txt
├── scripts/
│   ├── digest.py                       # Trace analysis script
│   └── prompt_template.txt             # LLM prompt for lesson extraction
│
└── workspace/                          # Mounted into container at /home/lean/workspace
    ├── opencode.json                   # OpenCode model + MCP config
    ├── .opencode/
    │   └── skills/
    │       └── lean-prover/
    │           └── SKILL.md            # Proving workflow skill
    ├── problems/                       # Theorem statements (sorry)
    ├── proofs/                         # Completed or partial proofs
    ├── traces/                         # Proving traces
    └── digests/                        # Digest output (gitignored)
```
