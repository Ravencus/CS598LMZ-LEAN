# Structured AI Theorem Proving with Human-Learnable Knowledge Extraction

CS598LMZ final project (Group 12). Codebase for the paper *Structured AI Theorem Proving with Human-Learnable Knowledge Extraction*, which contributes (1) a relational graduate-level math dataset with strategy hubs and audit-passing Lean 4 formalizations, and (2) an agentic Lean proving harness that composes a Lean compiler with a tool runtime (sympy / Mathematica) and exposes the proving sub-tasks (planning, formalization, retrieval, computation) as separately observable artifacts.

The report PDF is the separately submitted deliverable; this repository contains only the code, dataset, and run logs needed to reproduce its results.

---

## 1. Repository layout

```
.
├── Dockerfile                          # Container: Lean 4.29 + Mathlib + OpenCode + Python MCP
├── docker/                             # Lake project (lakefile.lean, lean-toolchain, scratch)
├── mcp_server/                         # Lean checker exposed over MCP
│   └── lean_checker_server.py
├── workspace/                          # Mounted into the container at /home/lean/workspace
│   ├── .opencode/skills/lean-prover/   #   SKILL.md: explore-plan-prove-revise workflow
│   ├── opencode.json                   #   OpenCode model + MCP config
│   ├── problems/                       #   Hand-curated problems used during dev
│   ├── proofs/                         #   Human-written reference proofs
│   └── traces/                         #   Hand-crafted proving traces (kept in repo)
├── scripts/
│   ├── digest.py                       # Trace-to-lesson distillation prototype (System 2 v0)
│   ├── prompt_template.txt
│   ├── graph_analysis.py               # Graph statistics on the relational dataset
│   └── digest_agent_diagram.py         # Diagram generation for the report
├── final-presentation/
│   └── d2_curation_v2/data/dataset_v2/ # Curated relational dataset (see §3)
├── final-report/
│   ├── scripts/                        # Eval runners, aggregators, figure generators
│   └── data/                           # All eval run logs and aggregate results (61 MB)
└── README.md                           # this file
```

---

## 2. Prerequisites

- **Docker** (the harness runs inside a precompiled Lean+Mathlib image).
- **Python 3.11+** on host, with `matplotlib`, `numpy`, `scipy`, `pandas` (for figure generation only).
- **API keys** (whichever models you intend to run):
  - OpenAI (Codex CLI / `gpt-5.5`, `gpt-5.4-mini`) — required to reproduce headline results.
  - DeepSeek API (`deepseek-v4-pro`, `deepseek-v4-flash`) — optional.
  - Anthropic API (`claude-opus-4-7`) — optional.

Place keys in plain text at the repo root:

```bash
echo "$OPENAI_KEY"     > .openai_api      # gitignored
echo "$DEEPSEEK_KEY"   > .deepseek_api    # gitignored
echo "$ANTHROPIC_KEY"  > .opus_api        # gitignored
```

The `.gitignore` keeps these files local; never commit them.

---

## 3. Dataset

The **curated relational dataset** is included in this repo at:

```
final-presentation/d2_curation_v2/data/dataset_v2/
├── nodes/                              # 461 node JSON files
│   ├── <problem-slug>.json             #   439 problem nodes
│   └── <hub-slug>.json                 #   22 strategy hub nodes
├── edges.json                          # 7,415 edges (problem-problem and problem-hub)
└── formalizations/                     # 233 Lean 4 theorem signatures
    └── <problem-slug>/
        ├── formalization.lean          #   Lean signature with `sorry` body
        └── audit.json                  #   FAITHFUL / MISMATCH / VACUOUS / UNCERTAIN verdict
```

The **148-statement `FAITHFUL` pool** (the evaluation set used throughout §3.2 of the report) is the subset of `formalizations/` whose `audit.json` is `FAITHFUL`. The fixed manifest used by all runners is:

```
final-report/data/manifest_faithful_100.json
```

(Schema: `n_problems`, `source`, `problems[]`. Each problem carries `problem_id`, `statement_en`, `verified_signature`, `difficulty`, `problem_type`, `domain`, `ground_truth_hubs`.)

**What is NOT in the repo:** the source Obsidian vault (455 markdown notes, ~160 MB) from which the dataset is derived. The vault is private personal study material. The pipeline that produces `dataset_v2/` from the vault is documented in §2.1 of the report and the scripts live in `final-presentation/d2_curation_v2/scripts/`; they are reproducible only if you have the source vault.

---

## 4. Building the container

The harness runs inside a Docker image with Lean 4.29.0-rc8, a precompiled Mathlib, OpenCode v1.3.3, and the Python MCP server.

```bash
# Option A (recommended): pull the prebuilt image
docker pull ghcr.io/ravencus/cs598lmz-lean:latest

# Option B: build from source (~30 min; needs ~10 GB disk for Mathlib oleans)
docker build -t ghcr.io/ravencus/cs598lmz-lean:latest .
```

The image entry point reads `/workspace` as the mounted repo root.

---

## 5. Reproducing the report

All commands below assume you start from the repo root with the container image available locally.

### 5.1 Main proving evaluation (Table `main-pass-rate`)

5 models × 2 conditions × 30 problems = 300 cells. Wall-clock: roughly 8 hours with default parallelism.

```bash
docker run --rm \
  -v $(pwd):/workspace \
  -v $(pwd)/.openai_api:/root/.openai_api:ro \
  -v $(pwd)/.deepseek_api:/root/.deepseek_api:ro \
  -v $(pwd)/.opus_api:/root/.opus_api:ro \
  ghcr.io/ravencus/cs598lmz-lean:latest \
  python3 /workspace/final-report/scripts/overnight_runner.py \
    --n-problems 30 --seed 42
```

Outputs land in `final-report/data/eval_overnight_opencode/<model>/<condition>/<pid>/outcome.json`. Aggregate them:

```bash
docker run --rm -v $(pwd):/workspace ghcr.io/ravencus/cs598lmz-lean:latest \
  python3 /workspace/final-report/scripts/aggregate_opencode.py
```

This produces `final-report/data/eval_overnight_opencode/aggregate.json`, which is the source of every cell in `tables/main-pass-rate.tex`, `tables/runtime.tex`, and Figure `outcome-breakdown`.

### 5.2 Capability decomposition (Table `capability-decomposition`)

For each vendor pair, an LLM judge reads disagreement traces and assigns one of `different_plan`, `same_plan_search_diff`, `same_plan_lean_impl_diff`.

```bash
docker run --rm -v $(pwd):/workspace ghcr.io/ravencus/cs598lmz-lean:latest \
  python3 /workspace/final-report/scripts/trace_compare.py \
    --pair gpt-5.5,gpt-5.4-mini

docker run --rm -v $(pwd):/workspace ghcr.io/ravencus/cs598lmz-lean:latest \
  python3 /workspace/final-report/scripts/trace_compare.py \
    --pair deepseek-v4-pro,deepseek-v4-flash
```

### 5.3 Check-call budget ablation (Table `kprobe`)

Reruns every failing `gpt-5.5` and `gpt-5.4-mini` cell with the MCP call budget doubled from 10 to 20, preserving passing cells.

```bash
bash final-report/scripts/run_kprobe.sh
```

Aggregate via `kprobe_compare.py`.

### 5.4 Hub-strategy classification (Table `hub-recall`)

`gpt-5.5` classifies each problem against the 22-hub catalog. Two conditions: `signature-only` (30 problems) and `proof-conditioned` (18 problems for which some model produced a passing Lean proof).

```bash
# Signature-only over the 30-problem stratified sample
docker run --rm -v $(pwd):/workspace ghcr.io/ravencus/cs598lmz-lean:latest \
  python3 /workspace/final-report/scripts/hub_recall_runner.py \
    --manifest /workspace/final-report/data/manifest_faithful_100.json \
    --prompt-mode direct

# Proof-conditioned over the 18-problem provable subset
docker run --rm -v $(pwd):/workspace ghcr.io/ravencus/cs598lmz-lean:latest \
  python3 /workspace/final-report/scripts/hub_recall_runner.py \
    --manifest /workspace/final-report/data/manifest_faithful_proof.json \
    --prompt-mode proof
```

### 5.5 Figures

All run on the host (no Docker needed) and read the JSON outputs above. Each script writes its output to a local `final-report/report-artifacts/figures/` directory it auto-creates (the directory is gitignored; the files are for inspection or external use).

```bash
pip install matplotlib numpy scipy pandas
python final-report/scripts/architecture_figures.py     # figure-curation.pdf
python final-report/scripts/dataset_overview_figure.py  # dataset-overview.pdf
python final-report/scripts/eval_figures.py             # outcome-breakdown.pdf
```

---

## 6. Running the prover interactively

The same harness is usable as an interactive proving session, useful for development and sanity checks.

```bash
docker run -it \
  -e OPENAI_API_KEY="$(cat .openai_api)" \
  -v $(pwd)/workspace:/home/lean/workspace \
  ghcr.io/ravencus/cs598lmz-lean:latest

# Inside the container:
opencode                                    # starts the agent with SKILL.md loaded
# or run a single problem:
opencode run -m gpt-5.5 "Prove in Lean 4: ∀ n : Nat, n + 0 = n"
```

After a session, export the trace:

```bash
opencode session list
opencode export <session-id>  > workspace/traces/my-session.json
```

The exported trace is the input format consumed by the System 2 prototype in `scripts/digest.py`.

---

## 7. Architecture summary

**System 1 — proving harness** (`workspace/`, `mcp_server/`, `docker/`):
- OpenCode agent configured by two `SKILL.md` files: a workflow skill (explore-plan-prove-revise) and a tools skill (sympy / Mathematica).
- The agent emits a Lean file plus zero or more sympy verifier scripts.
- Two checker backends consume the artifacts: Lean+Mathlib for deductive structure, a tool runtime for symbolic / numeric sub-claims.
- $K = 3$ attempts per problem with diagnostics fed back as trace context.

**System 2 — relational evaluation** (`final-report/scripts/hub_recall_runner.py`):
- Given a problem and a 22-hub catalog, the classifier returns the subset of hubs the problem instantiates.
- Macro F1 over 30 problems is the headline number. The proof-conditioned variant additionally feeds the type-checked Lean proof.

Detailed diagrams are reproduced by running the figure scripts in §5.5; they also appear in the submitted PDF.

---

## 8. License / citation

This is course work for CS598LMZ (Spring 2026) at UIUC. The report PDF and source LaTeX are the primary citable artifact:

```
Zihan Zheng. Structured AI Theorem Proving with Human-Learnable Knowledge Extraction.
CS598LMZ final report, University of Illinois Urbana-Champaign, 2026.
```

The source vault that seeds the dataset is private and not redistributed.
