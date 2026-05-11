"""
Stage 4 + 5: Hub determination + Problem graph assembly.

Reads:
  - data/note_graph.json (note-level graph, persistent)
  - data/subset.json (selected notes)
  - data/classified/*.json (per-note callouts + LLM verdicts)

Produces:
  - data/problem_graph_v2.json (final problem + hub graph with edges)

Stage 4 — Hub determination per note:
  - If ≥1 callout classified as `problem` → emit problem nodes
  - Else if note is in the top-3 hubs AND has ≥1 strategy_template callout → emit a hub node
  - A note can produce BOTH problem nodes AND a hub node if applicable
  - Otherwise (no problems, not a hub) → discard

Stage 5 — Edges:
  For each note-level edge {A, B}:
    For every node-from-A × every node-from-B: emit an undirected edge
"""

import json
import re
import unicodedata
from pathlib import Path
from collections import defaultdict

ROOT = Path("/workspace/final-presentation/d2_curation_v2")
GRAPH = ROOT / "data" / "note_graph.json"
SUBSET = ROOT / "data" / "subset.json"
CLASSIFIED_DIR = ROOT / "data" / "classified"
OUT = ROOT / "data" / "problem_graph_v2.json"


def safe_filename(title: str) -> str:
    s = unicodedata.normalize('NFKC', title).replace('/', '_').replace('\\', '_')
    return s


def slugify_for_id(text: str, fallback: str) -> str:
    """Make a presentable, ASCII-safe id from English text."""
    if not text:
        return fallback
    # Normalize and drop non-ASCII
    s = unicodedata.normalize('NFKD', text)
    s = re.sub(r'[^A-Za-z0-9 \-]', '', s)
    s = re.sub(r'\s+', '-', s).strip('-').lower()
    if not s:
        return fallback
    return s[:60]


HUB_DEGREE_THRESHOLD = 10  # any note in the subset with degree >= this AND with
                           # strategy_template content qualifies as a hub node


def main():
    note_graph = json.loads(GRAPH.read_text(encoding='utf-8'))
    subset = json.loads(SUBSET.read_text(encoding='utf-8'))
    hubs_set = set(subset['hubs'])  # the 3 explicit top hubs (still flagged separately)
    selected_titles = {n['title'] for n in subset['selected_notes']}

    # Build title -> english_title map from the persistent note graph
    title_to_english = {n['title']: n.get('english_title', '') for n in note_graph['nodes']}
    title_to_degree = {n['title']: n.get('degree', 0) for n in note_graph['nodes']}

    # Map note title → its classified callouts
    note_to_callouts = {}
    for cf in CLASSIFIED_DIR.glob('*.json'):
        if cf.name == '_summary.json': continue
        data = json.loads(cf.read_text(encoding='utf-8'))
        note_to_callouts[data['note_title']] = data

    # Stage 4: per-note classification → produce nodes
    note_to_nodes = defaultdict(list)  # note title → list of node dicts
    used_ids = set()

    def make_unique_id(base: str) -> str:
        if base not in used_ids:
            used_ids.add(base); return base
        for i in range(2, 999):
            candidate = f"{base}-{i}"
            if candidate not in used_ids:
                used_ids.add(candidate); return candidate
        return base + "-X"

    summary = {
        'problem_notes': 0, 'hub_notes': 0, 'hybrid_notes': 0, 'discarded_notes': 0,
        'total_problem_nodes': 0, 'total_hub_nodes': 0,
    }

    for title in selected_titles:
        cdata = note_to_callouts.get(title)
        if not cdata:
            print(f"  no classification for: {title}")
            continue

        callouts = cdata['callouts']
        problem_callouts = [c for c in callouts
                             if isinstance(c.get('classification_result'), dict)
                             and c['classification_result'].get('classification') == 'problem']
        strategy_callouts = [c for c in callouts
                              if isinstance(c.get('classification_result'), dict)
                              and c['classification_result'].get('classification') == 'strategy_template']

        is_top3_hub = title in hubs_set
        note_degree = title_to_degree.get(title, 0)
        # Hub eligibility: degree threshold OR explicit top-3
        qualifies_as_hub = (is_top3_hub or note_degree >= HUB_DEGREE_THRESHOLD)
        emitted = False

        english_source_note = title_to_english.get(title, '')

        # Emit problem nodes
        for c in problem_callouts:
            cls = c['classification_result']
            problem_meta = cls.get('if_problem') or {}
            english_title = cls.get('english_title', '')
            # ID base priority: english callout title -> english source note + index
            slug_from_callout = slugify_for_id(english_title, fallback='')
            slug_from_note = slugify_for_id(english_source_note, fallback='')
            idx_part = c['id'].split('#')[-1]
            if slug_from_callout:
                base_id = slug_from_callout
            elif slug_from_note:
                base_id = f"{slug_from_note}-{idx_part}"
            else:
                import hashlib
                base_id = 'p-' + hashlib.md5((title + c['id']).encode('utf-8')).hexdigest()[:8]
            node_id = make_unique_id(base_id)
            note_to_nodes[title].append({
                'id': node_id,
                'type': 'problem',
                'source_note': title,
                'english_source_note': english_source_note,
                'callout_id': c['id'],
                'english_title': english_title,
                'statement_en': problem_meta.get('statement_en', ''),
                'problem_type': problem_meta.get('problem_type', ''),
                'difficulty': problem_meta.get('difficulty', ''),
                'domain': problem_meta.get('domain', ''),
                'key_techniques': problem_meta.get('key_techniques', []),
                'prerequisites': problem_meta.get('prerequisites', []),
                'callout_body': c.get('body', ''),
            })
            emitted = True

        # Emit hub node if applicable (top-3 OR high-degree note with strategy templates)
        if qualifies_as_hub and strategy_callouts:
            # Merge all strategy templates into one hub node
            strategies = []
            for c in strategy_callouts:
                cls = c['classification_result']
                stm = cls.get('if_strategy_template') or {}
                strategies.append({
                    'callout_id': c['id'],
                    'english_title': cls.get('english_title', ''),
                    'strategy_name_en': stm.get('strategy_name_en', ''),
                    'summary_en': stm.get('summary_en', ''),
                    'applicability': stm.get('applicability', ''),
                    'callout_body': c.get('body', ''),
                })
            # ID priority: english source note slug → first strategy name slug → hash
            slug_from_en_note = slugify_for_id(english_source_note, fallback='')
            slug_from_title = slugify_for_id(title, fallback='')
            slug_from_strategy = slugify_for_id(strategies[0].get('strategy_name_en', ''), fallback='')
            import hashlib
            slug_fallback = 'hub-' + hashlib.md5(title.encode('utf-8')).hexdigest()[:8]
            hub_slug = slug_from_en_note or slug_from_title or slug_from_strategy or slug_fallback
            hub_id = make_unique_id(hub_slug + '-hub')
            note_to_nodes[title].append({
                'id': hub_id,
                'type': 'hub',
                'source_note': title,
                'english_source_note': english_source_note,
                'is_top3': is_top3_hub,
                'note_degree': note_degree,
                'strategies': strategies,
            })
            emitted = True

        # Stats
        if problem_callouts and emitted and any(n['type'] == 'hub' for n in note_to_nodes[title]):
            summary['hybrid_notes'] += 1
        elif problem_callouts:
            summary['problem_notes'] += 1
        elif emitted:
            summary['hub_notes'] += 1
        else:
            summary['discarded_notes'] += 1

        summary['total_problem_nodes'] += sum(1 for n in note_to_nodes[title] if n['type'] == 'problem')
        summary['total_hub_nodes'] += sum(1 for n in note_to_nodes[title] if n['type'] == 'hub')

    # Stage 5: build edges via Cartesian product on note-level edges
    # Only consider note edges where BOTH endpoints are in the subset AND both produced nodes
    edges_set = set()
    via_edge_lookup = defaultdict(list)
    for e in note_graph['edges']:
        a, b = e['a'], e['b']
        if a not in selected_titles or b not in selected_titles:
            continue
        nodes_a = note_to_nodes.get(a, [])
        nodes_b = note_to_nodes.get(b, [])
        for na in nodes_a:
            for nb in nodes_b:
                if na['id'] == nb['id']: continue
                pair = tuple(sorted([na['id'], nb['id']]))
                edges_set.add(pair)
                via_edge_lookup[pair].append({'note_a': a, 'note_b': b})

    edges = [{'a': p[0], 'b': p[1], 'via_note_edges': via_edge_lookup[p]} for p in sorted(edges_set)]

    # Flatten all nodes into a list
    all_nodes = []
    for title, nodes in note_to_nodes.items():
        all_nodes.extend(nodes)

    out = {
        'meta': {
            'directionality': 'undirected',
            'rule': 'Cartesian product of nodes across each note-level edge',
        },
        'nodes': all_nodes,
        'edges': edges,
        'summary': {
            **summary,
            'total_nodes': len(all_nodes),
            'total_edges': len(edges),
        },
    }

    OUT.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding='utf-8')

    print(f"\n=== ASSEMBLY SUMMARY ===")
    print(f"Notes: {summary['problem_notes']} problem-only / {summary['hub_notes']} hub-only / {summary['hybrid_notes']} hybrid / {summary['discarded_notes']} discarded")
    print(f"Total nodes: {len(all_nodes)} ({summary['total_problem_nodes']} problem + {summary['total_hub_nodes']} hub)")
    print(f"Total edges: {len(edges)}")
    print(f"Saved: {OUT}")


if __name__ == '__main__':
    main()
