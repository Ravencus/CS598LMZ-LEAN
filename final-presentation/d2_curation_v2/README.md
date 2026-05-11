# Dataset Curation v2

A cleaner rebuild of the D2 dataset, replacing the single-pass Codex extraction with a deterministic + LLM pipeline that uses graph structure as the canonical source of truth.

## Pipeline (6 stages, all in `scripts/`)

| Stage | Script | What it does | Output |
|-------|--------|--------------|--------|
| 1 | `01_build_note_graph.py` | Parse 455 vault notes, build undirected note-level graph from `[[wiki-links]]` | `data/note_graph.json` (persistent artifact — never recomputed) |
| 1.5 | `01b_translate_titles.py` | Codex (gpt-5.4) translates all 455 note titles to English; writes `english_title` field back into `note_graph.json` | (updates `note_graph.json` in-place) |
| 2 | `02_select_subset.py` | Top 3 hubs by undirected degree + top-15 highest-degree neighbors per hub, deduped | `data/subset.json` |
| 3a | `03_parse_callouts.py` | Deterministic regex parse of `> [!type] title\n> body...` blocks for the selected notes | `data/callouts/<title>.json` per note |
| 3b | `04_classify_callouts.py` | Codex (gpt-5.4) classifies each callout: problem / definition / strategy_template / remark; extracts structured metadata; English-only output enforced | `data/classified/<title>.json` per note |
| 4+5 | `05_assemble_graph.py` | Hub determination + Cartesian-product edge inheritance from note-level graph | `data/problem_graph_v2.json` |
| 6 | `06_format_output.py` | English scrubbing, validation, per-node files | `data/dataset_v2/` |

## Final numbers

- **127 problem nodes** + **15 hub nodes** = **142 total nodes**
- **1,942 edges** (undirected, deduplicated, inherited from note-level `[[]]` links via Cartesian product)
- **0 Chinese characters** in any presentation field (`english_title`, `statement_en`, `english_source_note`, all node IDs)
- **0 discarded notes** (all 30 selected notes contributed at least one node)

### Hub nodes (15)

3 top-3 by structural degree (locked from Stage 2):
- `term-by-term-estimates-hub` (degree 47, 9 strategies)
- `basic-methods-in-analysis-i-hub` (degree 45, 5 strategies)
- `integral-estimates-for-sums-hub` (degree 43, 2 strategies)

12 additional high-degree hubs (degree ≥ 10, with strategy_template content):
- `an-epsilon-of-room-hub` (degree 32)
- `piecewise-estimates-hub` (degree 42)
- `interchanging-sums-and-integrals-hub` (degree 18)
- `sum-estimates-via-summation-by-parts-hub` (degree 18)
- `using-known-asymptotics-to-derive-expansions-hub` (degree 16)
- `cauchy-condensation-test-hub` (degree 13)
- `re0-calculus-1-arithmetic-square-roots-by-newton-iteration-hub` (degree 12)
- `dirichlet-kernels-fail-fejer-kernels-approximate-identity-hub` (degree 11)
- `sequence-limits-via-piecewise-estimates-hub` (degree 11)
- `cauchy-convergence-criterion-hub` (degree 10)
- `integral-estimates-via-integration-by-parts-hub` (degree 10)
- `estimates-for-the-sum-of-prime-reciprocals-hub` (degree 10)

### Problem distribution

- **Difficulty:** 45 easy / 66 medium / 16 hard
- **Type:** 59 theorem / 30 example / 25 exercise / 8 lemma / 5 counterexample
- **Domain (top 5):** real analysis (85) / asymptotic analysis (15) / probability (5) / analytic number theory (4) / number theory (3); 14 distinct domains total.

## Contrast vs v1

| | v1 (`final-artifacts/data/codex_extraction/`) | v2 (this folder) |
|--|----------------------------------------------|------------------|
| Extraction unit | Whole note in one Codex call | Per-callout block, with deterministic pre-parsing |
| Hub identification | Implicit (we hand-picked by inspection) | Explicit (top-3 by degree + degree-threshold for hub-only notes) |
| Hub nodes as a category | Absent | First-class (15 nodes, with structured strategy templates) |
| Edges | Mixed (Codex-inferred + Cartesian) | Pure Cartesian product over note-level `[[]]` graph |
| Chinese in IDs / titles | Yes (e.g., `逐项估计-1`) | No (validated 0 violations) |
| Translation of note titles | None | All 455 titles translated; persistent in note graph |
| Reproducibility | Single Codex call per note (non-deterministic) | Stages 1, 2, 3a, 4, 5, 6 deterministic; only 1.5 and 3b call LLM |
| Provenance | Loose | Each node references its source callout + source note |

## Deferred

- **Lean formalization**: not part of v2. After v2 produces the clean dataset, a separate stage would auto-formalize selected problems and report compile rate.

## Files

```
d2_curation_v2/
├── README.md                          (this file)
├── scripts/
│   ├── 01_build_note_graph.py
│   ├── 01b_translate_titles.py
│   ├── 02_select_subset.py
│   ├── 03_parse_callouts.py
│   ├── 04_classify_callouts.py
│   ├── 05_assemble_graph.py
│   └── 06_format_output.py
└── data/
    ├── note_graph.json                (455 notes, 903 edges, with english_title)
    ├── subset.json                    (30 selected notes)
    ├── callouts/                      (raw callout blocks per note)
    ├── classified/                    (callouts + LLM verdicts per note)
    ├── problem_graph_v2.json          (final 142-node graph)
    ├── dataset_v2/
    │   ├── manifest.json              (counts + distributions + validation)
    │   ├── nodes/<id>.json            (per-node final form, English-clean)
    │   └── edges.json                 (1942 edges)
    ├── translate_titles.log
    └── classify_run.log
```

## Reproducibility

Re-run end-to-end:

```bash
python3 scripts/01_build_note_graph.py
python3 scripts/01b_translate_titles.py     # ~3 min Codex
python3 scripts/02_select_subset.py
python3 scripts/03_parse_callouts.py
python3 scripts/04_classify_callouts.py     # ~10-15 min Codex
python3 scripts/05_assemble_graph.py
python3 scripts/06_format_output.py
```

Stages 1, 2, 3a, 5, 6 are deterministic. Stages 1.5 and 3b call Codex CLI with `model="gpt-5.4"`.
