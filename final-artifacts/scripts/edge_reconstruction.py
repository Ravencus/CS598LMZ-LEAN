"""
Edge Reconstruction
Builds problem-level edges from note-level graph + Codex extraction results.
"""

import json
import argparse
from pathlib import Path
from collections import defaultdict

DATA_DIR = Path("/workspace/final-artifacts/data")


def load_note_graph():
    """Load note-level metadata and edges."""
    metadata = json.load(open(DATA_DIR / "vault_metadata.json"))
    edges = json.load(open(DATA_DIR / "vault_edges.json"))
    return metadata, edges


def parse_codex_json(text: str) -> dict:
    """Robustly parse JSON from Codex output (handles LaTeX backslash issues)."""
    import re
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    # Fix LaTeX backslashes: escape all backslashes, restore valid JSON escapes
    fixed = text.replace('\\', '\\\\')
    fixed = fixed.replace('\\\\"', '\\"')
    fixed = fixed.replace('\\\\n', '\\n')
    fixed = fixed.replace('\\\\t', '\\t')
    fixed = fixed.replace('\\\\r', '\\r')
    try:
        return json.loads(fixed)
    except json.JSONDecodeError:
        pass
    # Last resort: strip non-JSON backslashes
    fixed = re.sub(r'(?<!\\)\\(?!["\\nrt/bfu])', '', text)
    try:
        return json.loads(fixed)
    except json.JSONDecodeError:
        return None


def load_codex_results(results_dir: Path) -> dict:
    """Load Codex extraction results, keyed by note title."""
    results = {}
    if not results_dir.exists():
        return results
    for f in results_dir.glob("*.json"):
        if f.name == "batch_manifest.json":
            continue
        try:
            text = f.read_text(encoding='utf-8')
            data = parse_codex_json(text)
            if data and isinstance(data, dict) and "note_title" in data:
                results[data["note_title"]] = data
            elif data and isinstance(data, dict):
                # Use filename as title
                results[f.stem] = data
        except Exception:
            pass
    return results


def reconstruct_edges(metadata: list, note_edges: list, codex_results: dict) -> dict:
    """Build problem-level graph from note-level graph + extracted problems."""

    # Build note -> problems mapping
    note_problems = {}
    all_problems = []
    for title, result in codex_results.items():
        problems = result.get("problems", [])
        note_problems[title] = problems
        for p in problems:
            p["source_note"] = title
            all_problems.append(p)

    # Within-note edges: sequential problems in same note
    within_edges = []
    for title, problems in note_problems.items():
        for i in range(len(problems) - 1):
            within_edges.append({
                "source": problems[i]["id"],
                "target": problems[i + 1]["id"],
                "type": "within_note_progression",
                "source_note": title,
            })

    # Cross-note edges: inherit from note-level wiki-links
    cross_edges = []
    for edge in note_edges:
        src_note = edge["source"]
        tgt_note = edge["target"]
        src_problems = note_problems.get(src_note, [])
        tgt_problems = note_problems.get(tgt_note, [])
        # Connect all problems in source note to all in target note
        for sp in src_problems:
            for tp in tgt_problems:
                cross_edges.append({
                    "source": sp["id"],
                    "target": tp["id"],
                    "type": "cross_note_reference",
                    "source_note": src_note,
                    "target_note": tgt_note,
                })

    # Technique edges: if a note is classified as "technique",
    # connect it to all problems that list that technique
    technique_notes = {t: r for t, r in codex_results.items() if r.get("classification") == "technique"}
    technique_edges = []
    for tech_title, tech_data in technique_notes.items():
        techniques = tech_data.get("key_techniques_discussed", [])
        for p in all_problems:
            if p["source_note"] == tech_title:
                continue
            # Check if problem uses any of the techniques
            problem_techniques = set(t.lower() for t in p.get("key_techniques", []))
            for t in techniques:
                if t.lower() in problem_techniques:
                    technique_edges.append({
                        "source": tech_title,  # technique node
                        "target": p["id"],
                        "type": "technique_application",
                        "technique": t,
                    })

    problem_graph = {
        "nodes": all_problems,
        "within_note_edges": within_edges,
        "cross_note_edges": cross_edges,
        "technique_edges": technique_edges,
        "stats": {
            "total_problems": len(all_problems),
            "total_within_edges": len(within_edges),
            "total_cross_edges": len(cross_edges),
            "total_technique_edges": len(technique_edges),
            "notes_processed": len(codex_results),
        }
    }
    return problem_graph


def main():
    parser = argparse.ArgumentParser(description="Reconstruct problem-level edges")
    parser.add_argument("--results-dir", default=str(DATA_DIR / "codex_extraction" / "results"))
    parser.add_argument("--output", default=str(DATA_DIR / "problem_graph.json"))
    args = parser.parse_args()

    metadata, note_edges = load_note_graph()
    codex_results = load_codex_results(Path(args.results_dir))

    if not codex_results:
        print("No Codex extraction results found. Run prepare_codex_batch.py --run first.")
        print(f"Looked in: {args.results_dir}")
        return

    graph = reconstruct_edges(metadata, note_edges, codex_results)

    with open(args.output, 'w', encoding='utf-8') as f:
        json.dump(graph, f, ensure_ascii=False, indent=2)

    print(f"Problem graph saved to {args.output}")
    print(f"Stats: {json.dumps(graph['stats'], indent=2)}")


if __name__ == "__main__":
    main()
