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
    ├── problems/                       # Theorem statements
    ├── traces/                         # Session traces (gitignored)
    └── digests/                        # Digest output (gitignored)
```
