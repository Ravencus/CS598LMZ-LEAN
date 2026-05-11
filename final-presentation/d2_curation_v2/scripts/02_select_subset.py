"""
Stage 2: Subset selection (deterministic).

Rules (locked from discussion):
- Top 3 hubs by undirected total degree
- For each hub: take top-15 highest-degree 1-hop neighbors
- Subset = {3 hubs} ∪ {top-15 neighbors per hub}, deduplicated
- No diversity enforcement
"""

import json
from pathlib import Path
from collections import defaultdict

GRAPH = Path("/workspace/final-presentation/d2_curation_v2/data/note_graph.json")
OUT = Path("/workspace/final-presentation/d2_curation_v2/data/subset.json")

K_NEIGHBORS = 15
NUM_HUBS = 12


def main():
    g = json.loads(GRAPH.read_text(encoding='utf-8'))
    nodes = g['nodes']
    edges = g['edges']

    by_title = {n['title']: n for n in nodes}

    # Adjacency from undirected edges
    adj = defaultdict(set)
    for e in edges:
        adj[e['a']].add(e['b'])
        adj[e['b']].add(e['a'])

    # Top 3 hubs by degree (already sorted in node_graph.json)
    hubs = [n['title'] for n in nodes[:NUM_HUBS]]
    print(f"Top {NUM_HUBS} hubs by undirected degree:")
    for h in hubs:
        print(f"  {by_title[h]['degree']:>3}  {h}")

    # For each hub: take top-K neighbors by degree
    selected_via = defaultdict(list)
    for h in hubs:
        nbrs = list(adj[h])
        nbrs.sort(key=lambda t: -by_title[t]['degree'])
        top = nbrs[:K_NEIGHBORS]
        print(f"\n{h} (degree={by_title[h]['degree']}, total neighbors={len(nbrs)}):")
        for nbr in top:
            selected_via[nbr].append(h)
            print(f"  {by_title[nbr]['degree']:>3}  {nbr}")

    # Add hubs themselves to the selected set
    for h in hubs:
        if h not in selected_via:
            selected_via[h] = ['__hub__']
        else:
            selected_via[h].append('__hub__')

    # Build the subset
    selected = []
    for title, via in selected_via.items():
        n = by_title[title]
        is_hub = '__hub__' in via
        non_hub_via = [v for v in via if v != '__hub__']
        selected.append({
            'title': title,
            'degree': n['degree'],
            'tags': n['tags'],
            'char_count': n['char_count'],
            'is_hub': is_hub,
            'in_subset_via': non_hub_via,
        })
    selected.sort(key=lambda d: -d['degree'])

    # Stats
    shared = sum(1 for s in selected if len(s['in_subset_via']) >= 2)
    out = {
        'meta': {
            'k_neighbors_per_hub': K_NEIGHBORS,
            'num_hubs': NUM_HUBS,
        },
        'hubs': hubs,
        'selected_notes': selected,
        'stats': {
            'total_unique_notes': len(selected),
            'hubs_in_subset': len(hubs),
            'neighbors_in_subset': len(selected) - len(hubs),
            'shared_across_hubs': shared,
        },
    }

    OUT.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f"\n=== SUBSET ===")
    print(f"Total unique notes selected: {len(selected)}")
    print(f"Shared across multiple hubs: {shared}")
    print(f"Saved to: {OUT}")


if __name__ == '__main__':
    main()
