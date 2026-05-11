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

The eval scripts shell out to local CLI tools and the local Lean toolchain. Everything runs on the host (or inside the devcontainer at `.devcontainer/`, which bind-mounts the repo to `/workspace`); the `ghcr.io/ravencus/cs598lmz-lean:latest` Docker image is used only for interactive proving sessions (§5), not for the headline eval.

**Host requirements:**

- **Python 3.11+** with `matplotlib`, `numpy`, `scipy`, `pandas`.
- **Lean 4 toolchain via `elan`** (matches `docker/lean-toolchain` — Lean 4.29.0-rc8). Inside `docker/`, run `lake exe cache get` once to download precompiled Mathlib (~5 GB, ~10 min on broadband).
- **`codex` CLI**, authenticated via ChatGPT subscription (OAuth). Required for `gpt-5.5` and `gpt-5.4-mini`. See <https://github.com/openai/codex>.
- **`claude` CLI** (Claude Code), required for `claude-opus-4-7` and for the DeepSeek models (the harness redirects `claude --print` at DeepSeek's Anthropic-compat endpoint). See <https://github.com/anthropics/claude-code>.
- **API keys** as plain text files at the repo root:
  ```bash
  echo "$DEEPSEEK_KEY"   > .deepseek_api    # gitignored
  echo "$ANTHROPIC_KEY"  > .opus_api        # gitignored
  ```
  (`codex` handles OAuth itself; no key file needed for OpenAI.)

**Path assumption:** several scripts (notably `unified_harness.py` and `overnight_runner.py`) hard-code `/workspace/...` as the repo root. Use one of:
  - The devcontainer at `.devcontainer/devcontainer.json` (auto bind-mounts the repo to `/workspace`).
  - A symlink: `sudo ln -s "$(pwd)" /workspace` from the repo root.
  - Or edit `REPO_ROOT` in those two files.

---

## 3. Dataset

The **curated relational dataset** is included in this repo at:

```
final-presentation/d2_curation_v2/data/
├── dataset_v2/
│   ├── nodes/                          # 461 node JSON files
│   │   ├── <problem-slug>.json         #   439 problem nodes
│   │   └── <hub-slug>.json             #   22 strategy hub nodes
│   ├── edges.json                      # 7,415 edges (problem-problem and problem-hub)
│   └── manifest.json                   # dataset version metadata
└── formalizations/                     # 440 problem-slug subdirectories of formalization attempts
    └── <problem-slug>/
        ├── formalization.lean          #   Lean signature with `sorry` body
        └── audit.json                  #   FAITHFUL / MISMATCH / VACUOUS / UNCERTAIN verdict
```

Of the 440 formalization attempts, 233 produce a Lean signature that compiles. Of those 233, **148 are labeled `FAITHFUL`** by the audit judge and form the proving-evaluation pool used in §3.2 of the report. The fixed 30-problem stratified sample drawn from that pool (the actual set every cell in §4.1 was run on) is at:

```
final-report/data/eval_snapshots/20260510_083526_partial/manifest.json
```

A 100-problem manifest is also kept at `final-report/data/manifest_faithful_100.json` for one-off experimentation, and an 18-problem proof-conditioned manifest at `final-report/data/manifest_faithful_proof.json` for §4.4. All three follow the same schema: `n_problems`, `source`, `problems[]`. Each problem carries `problem_id`, `statement_en`, `verified_signature`, `difficulty`, `problem_type`, `domain`, `ground_truth_hubs` (the `manifest_faithful_proof.json` problems additionally carry `final_proof` and `proof_source`).

**What is NOT in the repo:** the source Obsidian vault (455 markdown notes, ~160 MB) from which the dataset is derived. The vault is private personal study material. The pipeline that produces `dataset_v2/` from the vault is documented in §2.1 of the report and the scripts live in `final-presentation/d2_curation_v2/scripts/`; they are reproducible only if you have the source vault.

---

## 4. Reproducing the report

All commands run from the repo root, with the prerequisites in §2 installed, the `/workspace` path mapped, and the eval data already present under `final-report/data/`. To rerun any experiment from scratch, delete the matching `outcome.json` files first so the runner recomputes them.

### 4.1 Main proving evaluation (Table `main-pass-rate`)

5 models × 2 conditions × 30 problems = 300 cells. Wall-clock: roughly 8 hours with default parallelism. The runner defaults to the 30-problem stratified-sample manifest at `final-report/data/eval_snapshots/20260510_083526_partial/manifest.json`. The model set defaults to the four cost-comparable models only, so to reproduce the full report (which includes `claude-opus-4-7`) pass `--models` explicitly:

```bash
python3 final-report/scripts/opencode_runner.py \
  --models deepseek-v4-flash deepseek-v4-pro gpt-5.4-mini gpt-5.5 claude-opus-4-7
```

To run only the four-model subset (240 cells, ~5 hours), omit `--models`. The runner additionally accepts `--manifest`, `--conditions`, `--budget`, `--wall`, `--parallel`, `--limit`, `--eval-dir`; defaults match the production settings.

Per-cell outputs land in `final-report/data/eval_overnight_opencode/<model>/<condition>/<pid>/`:
- `outcome.json` — verdict + metadata.
- `final.lean` — the produced proof.
- `stream.jsonl` — full OpenCode trace.
- `stderr.log`, `prompt.txt`, `final_text.txt` — supporting artifacts.

Aggregate them:

```bash
python3 final-report/scripts/aggregate_opencode.py
```

This produces `final-report/data/eval_overnight_opencode/aggregate.json`, the source of every cell in `main-pass-rate`, `runtime`, and the `outcome-breakdown` figure.

Note: there is also an older `overnight_runner.py` in the same directory which writes to `final-report/data/eval_overnight/` (a separate "Arm A" pipeline). It is not the runner that produced the report's headline numbers; use `opencode_runner.py` for reproduction.

### 4.2 Capability decomposition (Table `capability-decomposition`)

For each within-vendor pair (gpt-5.5 vs gpt-5.4-mini, deepseek-v4-pro vs deepseek-v4-flash), an LLM judge reads disagreement traces (from §4.1's `stream.jsonl`) and assigns one of `different_plan`, `same_plan_search_diff`, `same_plan_lean_impl_diff`. Both pairs are iterated in a single invocation:

```bash
python3 final-report/scripts/trace_compare.py
```

Outputs land in `final-report/data/eval_overnight_opencode/trace_compare/`. For the additional cross-vendor `gpt-5.5` vs `claude-opus-4-7` comparison (reported alongside the vendor pairs):

```bash
python3 final-report/scripts/trace_compare_55_vs_opus.py
```

This writes to `final-report/data/eval_overnight_opencode/trace_compare_55_vs_opus/`.

### 4.3 Check-call budget ablation (Table `kprobe`)

Reruns every failing `gpt-5.5` and `gpt-5.4-mini` cell with the MCP call budget doubled from 10 to 20, preserving passing cells. The shell wrapper handles seeding and re-aggregation.

```bash
bash final-report/scripts/run_kprobe.sh
```

Outputs land in `final-report/data/eval_kprobe_K20/`. **Note:** `run_kprobe.sh` sets `REPO=/home/raven/Desktop/lean` unconditionally at the top of the script (not `${REPO:-...}`), so an environment-variable override has no effect. Edit that line in `run_kprobe.sh` to your clone path before running.

### 4.4 Hub-strategy classification (Table `hub-recall`)

`gpt-5.5` classifies each problem against the 22-hub catalog. Two conditions: `signature-only` (the same 30 stratified problems as §4.1) and `proof-conditioned` (the 18 problems for which some model produced a passing Lean proof).

```bash
# Signature-only over the 30-problem stratified sample
# (defaults to eval_snapshots/20260510_083526_partial/manifest.json — same 30 as §4.1)
python3 final-report/scripts/hub_recall_runner.py --prompt-mode direct

# Proof-conditioned over the 18-problem provable subset
# (Use --eval-dir to keep its outputs separate from the signature-only run —
# both runs would otherwise write under the same hub_recall/<model>/ path.)
python3 final-report/scripts/hub_recall_runner.py \
  --manifest final-report/data/manifest_faithful_proof.json \
  --prompt-mode proof \
  --eval-dir final-report/data/eval_overnight_opencode/hub_recall_proof
```

Signature-only outputs land in `final-report/data/eval_overnight_opencode/hub_recall/<model>/`; proof-conditioned outputs in `.../hub_recall_proof/<model>/`. Each run produces an `aggregate.json` with macro/micro precision, recall, F1. `eval_figures.py` in §4.5 reads both paths.

### 4.5 Figures

Run on the host. They read the JSON outputs above and write PDF/PNG to a `final-report/report-artifacts/figures/` directory each script auto-creates (gitignored; the files are for inspection or external use). Note: `dataset_overview_figure.py` and `eval_figures.py` currently hard-code `ROOT = Path('/home/raven/Desktop/lean')`; edit that line if your repo lives elsewhere.

`architecture_figures.py` and `dataset_overview_figure.py` are self-contained. `eval_figures.py` requires five upstream aggregates: the main `aggregate.json` from §4.1, both `trace_compare/aggregate.json` and `trace_compare_55_vs_opus/aggregate.json` from §4.2, and both the signature-only (`hub_recall/<model>/aggregate.json`) and proof-conditioned (`hub_recall_proof/<model>/aggregate.json`) aggregates from §4.4. These are already shipped in `final-report/data/`, so running the figure script directly on a fresh clone works. If you have rerun the eval from scratch, run §4.1 → §4.2 → §4.4 first, then:

```bash
python3 final-report/scripts/architecture_figures.py     # figure-curation.pdf
python3 final-report/scripts/dataset_overview_figure.py  # dataset-overview.pdf
python3 final-report/scripts/eval_figures.py             # outcome-breakdown.pdf
```

---

## 5. Running the prover interactively

For interactive development and one-off proof attempts (not used for the eval), the prebuilt Docker image bundles Lean 4 + Mathlib + OpenCode in a single environment.

```bash
docker pull ghcr.io/ravencus/cs598lmz-lean:latest
# Or build from source (~30 min, ~10 GB):
docker build -t ghcr.io/ravencus/cs598lmz-lean:latest .
```

OpenCode inside the container uses its own API key (separate from the codex CLI's OAuth-based auth in §2). Sign up at <https://opencode.ai> and store the key locally:

```bash
echo "$OPENCODE_KEY" > .opencode_api    # gitignored
```

Then start the container:

```bash
docker run -it \
  -e OPENCODE_API_KEY="$(cat .opencode_api)" \
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

## 6. Architecture summary

**System 1 — proving harness** (`workspace/`, `mcp_server/`, `docker/`):
- OpenCode agent configured by `workspace/.opencode/skills/lean-prover/SKILL.md` (the workflow skill: explore-plan-prove-revise). In the `with_sympy` condition, the harness additionally prepends a sympy-tools block to the system prompt at run time, conceptually a second skill though not a separate file on disk.
- The agent emits a Lean file plus zero or more sympy verifier scripts.
- Two checker backends consume the artifacts: Lean+Mathlib for deductive structure, a tool runtime for symbolic / numeric sub-claims.
- $K = 3$ attempts per problem with diagnostics fed back as trace context.

**System 2 — relational evaluation** (`final-report/scripts/hub_recall_runner.py`):
- Given a problem and a 22-hub catalog, the classifier returns the subset of hubs the problem instantiates.
- Macro F1 over 30 problems is the headline number. The proof-conditioned variant additionally feeds the type-checked Lean proof.

Detailed diagrams are reproduced by running the figure scripts in §4.5; they also appear in the submitted PDF.

---

## 7. License / citation

This is course work for CS598LMZ (Spring 2026) at UIUC. The report PDF and source LaTeX are the primary citable artifact:

```
Zihan Zheng. Structured AI Theorem Proving with Human-Learnable Knowledge Extraction.
CS598LMZ final report, University of Illinois Urbana-Champaign, 2026.
```

The source vault that seeds the dataset is private and not redistributed.
