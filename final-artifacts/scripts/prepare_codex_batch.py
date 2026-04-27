"""
Prepare Codex Batch for Dataset Curation
Selects a subgraph from the vault and prepares extraction tasks for Codex CLI.
"""

import json
import os
import argparse
from pathlib import Path

MATH_DIR = Path("/workspace/math-notes/笔记共享vault/math")
DATA_DIR = Path("/workspace/final-artifacts/data")
CODEX_OUT = DATA_DIR / "codex_extraction"

EXTRACTION_PROMPT = """You are a mathematics knowledge extraction agent. Given a mathematics note written in Chinese, extract structured information.

## Output Format (JSON)
```json
{
  "note_title": "<title>",
  "classification": "<one of: problem, technique, theory, example_collection>",
  "summary_en": "<1-2 sentence English summary of what this note is about>",
  "problems": [
    {
      "id": "<note_title_short>-<number>",
      "statement_en": "<problem statement translated to English>",
      "statement_zh": "<original problem statement in Chinese>",
      "type": "<one of: theorem, lemma, exercise, example, counterexample, definition>",
      "difficulty": "<one of: easy, medium, hard>",
      "domain": "<math domain in English, e.g. real analysis, probability, number theory>",
      "key_techniques": ["<technique 1>", "<technique 2>"],
      "prerequisites": ["<prerequisite concept 1>"]
    }
  ],
  "key_techniques_discussed": ["<technique 1 in English>"],
  "connections_mentioned": ["<related topic 1>"]
}
```

## Rules
1. Extract ALL distinct problems, theorems, lemmas, and exercises from the note.
2. Translate mathematical statements accurately to English. Keep mathematical notation intact.
3. For technique notes (no specific problems), set classification to "technique" and list the techniques in key_techniques_discussed.
4. Be concise but precise in summaries and translations.
5. Output ONLY the JSON, no other text.

## Note Content
"""


def select_subgraph(hub_title: str, max_nodes: int = 20) -> list[str]:
    """Select a connected subgraph centered on a single hub node."""
    metadata = json.load(open(DATA_DIR / "vault_metadata.json"))
    edges = json.load(open(DATA_DIR / "vault_edges.json"))
    return _select_from_hubs([hub_title], max_nodes, metadata, edges)


def select_multi_hub_subgraph(hub_titles: list[str], max_nodes: int = 40) -> list[str]:
    """Select a connected subgraph from multiple hub neighborhoods.
    Picks nodes that have dense inter-connections (shared between hubs)."""
    metadata = json.load(open(DATA_DIR / "vault_metadata.json"))
    edges = json.load(open(DATA_DIR / "vault_edges.json"))
    return _select_from_hubs(hub_titles, max_nodes, metadata, edges)


def _select_from_hubs(hub_titles: list[str], max_nodes: int, metadata: list, edges: list) -> list[str]:
    """Core subgraph selection from one or more hubs."""
    existing = set(n["title"] for n in metadata)
    degree_map = {n["title"]: n["in_degree"] for n in metadata}

    # Collect neighbors for each hub
    hub_neighbors = {}
    for hub in hub_titles:
        neighbors = set()
        for e in edges:
            if e["source"] == hub:
                neighbors.add(e["target"])
            if e["target"] == hub:
                neighbors.add(e["source"])
        hub_neighbors[hub] = neighbors & existing

    # Score each neighbor: prefer nodes connected to multiple hubs (dense inter-connections)
    all_neighbors = set()
    neighbor_score = {}
    for hub, neighbors in hub_neighbors.items():
        all_neighbors |= neighbors
        for n in neighbors:
            neighbor_score[n] = neighbor_score.get(n, 0) + 1

    # Sort by: (1) number of hub connections, (2) in-degree
    valid_neighbors = [n for n in all_neighbors if n not in hub_titles]
    valid_neighbors.sort(key=lambda x: (neighbor_score.get(x, 0), degree_map.get(x, 0)), reverse=True)

    # Build subgraph: hubs first, then ranked neighbors
    subgraph = list(hub_titles)
    for n in valid_neighbors:
        if len(subgraph) >= max_nodes:
            break
        if n not in subgraph:
            subgraph.append(n)

    return subgraph


def prepare_batch(subgraph: list[str], output_dir: Path):
    """Prepare individual extraction tasks for Codex."""
    output_dir.mkdir(parents=True, exist_ok=True)

    tasks = []
    for title in subgraph:
        note_path = MATH_DIR / f"{title}.md"
        if not note_path.exists():
            print(f"  SKIP: {title} (file not found)")
            continue

        content = note_path.read_text(encoding='utf-8')

        # Save the task prompt
        task_file = output_dir / f"{title.replace('/', '_')}_task.md"
        task_file.write_text(EXTRACTION_PROMPT + content, encoding='utf-8')

        tasks.append({
            "title": title,
            "file": str(note_path),
            "task_file": str(task_file),
            "char_count": len(content),
        })

    # Save task manifest
    manifest_path = output_dir / "batch_manifest.json"
    with open(manifest_path, 'w', encoding='utf-8') as f:
        json.dump(tasks, f, ensure_ascii=False, indent=2)

    print(f"\nPrepared {len(tasks)} extraction tasks in {output_dir}")
    print(f"Manifest: {manifest_path}")
    return tasks


def run_codex_extraction(tasks: list[dict], output_dir: Path, limit: int = 0):
    """Run Codex CLI on each task."""
    import subprocess
    import tempfile

    results_dir = output_dir / "results"
    results_dir.mkdir(exist_ok=True)

    if limit > 0:
        tasks = tasks[:limit]

    for i, task in enumerate(tasks, 1):
        title = task["title"]
        print(f"\n[{i}/{len(tasks)}] Extracting: {title}")

        result_file = results_dir / f"{title.replace('/', '_')}.json"
        if result_file.exists():
            print(f"  Already extracted, skipping.")
            continue

        task_content = Path(task["task_file"]).read_text(encoding='utf-8')

        try:
            # Use -o to capture output to file, pass prompt as argument
            with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as tmp:
                codex_out = tmp.name

            result = subprocess.run(
                ["codex", "exec", "-o", codex_out, task_content],
                capture_output=True, text=True, timeout=180
            )

            if result.returncode == 0 and Path(codex_out).exists():
                output = Path(codex_out).read_text().strip()
                if output:
                    result_file.write_text(output, encoding='utf-8')
                    print(f"  Saved ({len(output)} chars)")
                else:
                    print(f"  Empty output")
            else:
                print(f"  Failed (rc={result.returncode})")
                if result.stderr:
                    print(f"  stderr: {result.stderr[:200]}")

            try:
                os.unlink(codex_out)
            except Exception:
                pass

        except subprocess.TimeoutExpired:
            print(f"  Timeout (180s)")
        except Exception as e:
            print(f"  Error: {e}")


def main():
    parser = argparse.ArgumentParser(description="Prepare Codex extraction batch")
    parser.add_argument("--hub", default="逐项估计", help="Hub node to center subgraph on")
    parser.add_argument("--multi-hub", action="store_true", help="Use multiple hubs for denser subgraph")
    parser.add_argument("--max-nodes", type=int, default=40, help="Max nodes in subgraph")
    parser.add_argument("--run", action="store_true", help="Actually run Codex extraction")
    parser.add_argument("--limit", type=int, default=3, help="Limit Codex runs (for testing)")
    args = parser.parse_args()

    if args.multi_hub:
        hubs = ["逐项估计", "和的积分估计", "分段估计"]
        print(f"Selecting multi-hub subgraph from: {hubs}")
        subgraph = select_multi_hub_subgraph(hubs, args.max_nodes)
    else:
        print(f"Selecting subgraph centered on: {args.hub}")
        subgraph = select_subgraph(args.hub, args.max_nodes)
    print(f"Selected {len(subgraph)} notes:")
    for n in subgraph:
        print(f"  - {n}")

    tasks = prepare_batch(subgraph, CODEX_OUT)

    if args.run:
        print(f"\nRunning Codex extraction (limit={args.limit})...")
        run_codex_extraction(tasks, CODEX_OUT, limit=args.limit)
    else:
        print(f"\nDry run. Use --run to execute Codex extraction.")
        print(f"Or run manually: codex exec '<prompt>' for each task file.")


if __name__ == "__main__":
    main()
