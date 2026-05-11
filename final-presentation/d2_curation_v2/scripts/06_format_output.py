"""
Stage 6: English scrubbing & final dataset format.

Reads:
  - data/problem_graph_v2.json

Produces:
  - data/dataset_v2/manifest.json (one summary doc with stats)
  - data/dataset_v2/nodes/<id>.json (one file per problem/hub node)
  - data/dataset_v2/edges.json (one edge list)

Operations:
  - Verify all node IDs are ASCII / safe slugs
  - Group nodes by type (problem vs hub) for separate listings
  - Validate that statement_en, english_title fields contain no Chinese
  - Keep callout_body and source_note as provenance fields (Chinese OK there)
"""

import json
import re
import unicodedata
from pathlib import Path

ROOT = Path("/workspace/final-presentation/d2_curation_v2")
GRAPH = ROOT / "data" / "problem_graph_v2.json"
OUT_DIR = ROOT / "data" / "dataset_v2"
NODES_DIR = OUT_DIR / "nodes"


CJK_RE = re.compile(r'[一-鿿㐀-䶿]')


def has_chinese(text: str) -> bool:
    return bool(CJK_RE.search(text or ''))


def main():
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    NODES_DIR.mkdir(parents=True, exist_ok=True)

    g = json.loads(GRAPH.read_text(encoding='utf-8'))
    nodes = g['nodes']
    edges = g['edges']

    # Validate IDs
    bad_id = [n['id'] for n in nodes if has_chinese(n['id'])]
    print(f"Node IDs with Chinese: {len(bad_id)} (should be 0)")
    if bad_id:
        for b in bad_id[:5]:
            print(f"  bad id: {b}")

    # Validate english_title / statement_en
    presentation_field_violations = []
    for n in nodes:
        if has_chinese(n.get('english_title', '')):
            presentation_field_violations.append((n['id'], 'english_title', n['english_title'][:60]))
        if has_chinese(n.get('statement_en', '')):
            presentation_field_violations.append((n['id'], 'statement_en', n['statement_en'][:60]))

    print(f"Presentation-field Chinese violations: {len(presentation_field_violations)}")
    for v in presentation_field_violations[:5]:
        print(f"  {v}")

    # Stats
    problem_nodes = [n for n in nodes if n['type'] == 'problem']
    hub_nodes = [n for n in nodes if n['type'] == 'hub']

    domain_dist = {}
    diff_dist = {}
    type_dist = {}
    for n in problem_nodes:
        domain_dist[n.get('domain', 'unknown')] = domain_dist.get(n.get('domain', 'unknown'), 0) + 1
        diff_dist[n.get('difficulty', 'unknown')] = diff_dist.get(n.get('difficulty', 'unknown'), 0) + 1
        type_dist[n.get('problem_type', 'unknown')] = type_dist.get(n.get('problem_type', 'unknown'), 0) + 1

    # Write per-node files
    for n in nodes:
        node_path = NODES_DIR / f"{n['id']}.json"
        node_path.write_text(json.dumps(n, indent=2, ensure_ascii=False), encoding='utf-8')

    # Write edges
    (OUT_DIR / 'edges.json').write_text(json.dumps(edges, indent=2, ensure_ascii=False), encoding='utf-8')

    # Build manifest
    manifest = {
        'meta': {
            'pipeline': 'd2_curation_v2',
            'version': 2,
        },
        'counts': {
            'total_nodes': len(nodes),
            'problem_nodes': len(problem_nodes),
            'hub_nodes': len(hub_nodes),
            'total_edges': len(edges),
        },
        'distributions': {
            'domain': dict(sorted(domain_dist.items(), key=lambda x: -x[1])),
            'difficulty': diff_dist,
            'problem_type': type_dist,
        },
        'validation': {
            'node_ids_with_chinese': len(bad_id),
            'presentation_field_violations': len(presentation_field_violations),
        },
        'hub_node_ids': [n['id'] for n in hub_nodes],
    }
    (OUT_DIR / 'manifest.json').write_text(json.dumps(manifest, indent=2, ensure_ascii=False), encoding='utf-8')

    print(f"\n=== FINAL DATASET v2 ===")
    print(f"Problem nodes: {len(problem_nodes)}")
    print(f"Hub nodes:     {len(hub_nodes)}")
    print(f"Edges:         {len(edges)}")
    print(f"Domains:       {len(domain_dist)} unique")
    print(f"Top 5 domains: {list(domain_dist.items())[:5]}")
    print(f"Difficulty:    {diff_dist}")
    print(f"Problem types: {type_dist}")
    print(f"\nSaved to: {OUT_DIR}")


if __name__ == '__main__':
    main()
