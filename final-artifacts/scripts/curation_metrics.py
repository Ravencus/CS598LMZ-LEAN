"""
Compute quality metrics for the curated dataset.
Category balance, domain diversity, edge faithfulness, formalization compile rate.
"""

import json
import os
import re
from pathlib import Path
from collections import Counter

DATA_DIR = Path("/workspace/final-artifacts/data")


def parse_codex_json(text: str):
    """Robustly parse JSON from Codex output."""
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    fixed = text.replace('\\', '\\\\')
    fixed = fixed.replace('\\\\"', '\\"').replace('\\\\n', '\\n').replace('\\\\t', '\\t').replace('\\\\r', '\\r')
    try:
        return json.loads(fixed)
    except:
        return None


def compute_metrics():
    results_dir = DATA_DIR / "codex_extraction" / "results"
    metadata = json.load(open(DATA_DIR / "vault_metadata.json"))
    meta_map = {n["title"]: n for n in metadata}

    # Load all Codex results
    extractions = {}
    for f in results_dir.iterdir():
        if f.suffix != '.json':
            continue
        data = parse_codex_json(f.read_text(encoding='utf-8'))
        if data:
            title = data.get("note_title", f.stem)
            extractions[title] = data

    print(f"=== Dataset Curation Quality Metrics ===\n")
    print(f"Notes processed: {len(extractions)}")

    # Category balance
    classifications = Counter()
    for title, data in extractions.items():
        classifications[data.get("classification", "unknown")] += 1
    print(f"\n## Category Balance")
    for cls, count in classifications.most_common():
        print(f"  {cls}: {count} ({count/len(extractions)*100:.0f}%)")

    # Problem count and types
    total_problems = 0
    problem_types = Counter()
    difficulties = Counter()
    domains = Counter()
    for data in extractions.values():
        problems = data.get("problems", [])
        total_problems += len(problems)
        for p in problems:
            problem_types[p.get("type", "unknown")] += 1
            difficulties[p.get("difficulty", "unknown")] += 1
            domains[p.get("domain", "unknown")] += 1

    print(f"\n## Problem Statistics")
    print(f"  Total problems extracted: {total_problems}")
    print(f"  Avg problems per note: {total_problems/len(extractions):.1f}" if extractions else "")
    print(f"  Problem types: {dict(problem_types.most_common())}")
    print(f"  Difficulties: {dict(difficulties.most_common())}")

    # Domain diversity
    print(f"\n## Domain Diversity")
    print(f"  Unique domains: {len(domains)}")
    for d, count in domains.most_common(10):
        print(f"  {d}: {count}")

    # Hub/leaf coverage in subgraph (match by filename stem since Codex may alter titles)
    tiers_in_subgraph = Counter()
    for title in extractions:
        meta = meta_map.get(title, None)
        if meta is None:
            # Try matching by filename stem (results are saved as {title}.json)
            for m in metadata:
                if m["title"] in title or title in m["title"]:
                    meta = m
                    break
        tiers_in_subgraph[meta.get("tier", "unknown") if meta else "unknown"] += 1

    print(f"\n## Hub/Leaf Coverage")
    for tier, count in sorted(tiers_in_subgraph.items()):
        print(f"  {tier}: {count}")

    # Tag coverage
    tags_in_subgraph = Counter()
    for title in extractions:
        meta = meta_map.get(title, {})
        for t in meta.get("tags", []):
            if t != "math":
                tags_in_subgraph[t] += 1

    print(f"\n## Tag Coverage")
    print(f"  Unique tags in subgraph: {len(tags_in_subgraph)}")
    for t, count in tags_in_subgraph.most_common(10):
        print(f"  {t}: {count}")

    # Compile results
    metrics = {
        "notes_processed": len(extractions),
        "total_problems": total_problems,
        "avg_problems_per_note": round(total_problems / len(extractions), 1) if extractions else 0,
        "category_balance": dict(classifications),
        "problem_types": dict(problem_types),
        "difficulties": dict(difficulties),
        "domain_diversity": len(domains),
        "domains": dict(domains.most_common(15)),
        "tier_coverage": dict(tiers_in_subgraph),
        "tag_diversity": len(tags_in_subgraph),
        "top_tags": dict(tags_in_subgraph.most_common(10)),
    }

    out_path = Path("/workspace/final-artifacts/results/curation_metrics.json")
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with open(out_path, 'w', encoding='utf-8') as f:
        json.dump(metrics, f, indent=2, ensure_ascii=False)
    print(f"\nMetrics saved to {out_path}")

    return metrics


if __name__ == "__main__":
    compute_metrics()
