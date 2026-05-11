"""
Stage 1: Build the note-level graph as a persistent artifact.

- Parse all .md notes in /workspace/math-notes/笔记共享vault/math
- Extract YAML frontmatter tags
- Extract [[wiki-links]], filter out media files
- Build an UNDIRECTED graph (collapse each [[B]] in note A to a single edge {A, B})
- Compute total degree per note
- Write to data/note_graph.json

This file is the foundation for all downstream stages. It is read, never recomputed.
"""

import json
import re
from pathlib import Path
from collections import Counter

VAULT_DIR = Path("/workspace/math-notes/笔记共享vault/math")
OUT = Path("/workspace/final-presentation/d2_curation_v2/data/note_graph.json")
OUT.parent.mkdir(parents=True, exist_ok=True)

# --- regexes ---
LINK_RE = re.compile(r'\[\[([^\]]+)\]\]')
HEADING_RE = re.compile(r'^(#{1,6})\s+(.+)$', re.MULTILINE)

MEDIA_EXTS = ('.png', '.jpg', '.jpeg', '.gif', '.svg', '.webp', '.pdf', '.bmp', '.tif', '.tiff', '.mp4', '.webm')


def extract_tags(content: str) -> list[str]:
    """YAML frontmatter tag extraction (no PyYAML)."""
    if not content.startswith('---'):
        return []
    end = content.find('---', 3)
    if end == -1:
        return []
    front = content[3:end]
    in_tags = False
    tags = []
    for line in front.split('\n'):
        s = line.strip()
        if s.startswith('tags:'):
            in_tags = True
            inline = s[5:].strip()
            if inline.startswith('['):
                tags = [t.strip().strip('"').strip("'") for t in inline.strip('[]').split(',') if t.strip()]
                break
            continue
        if in_tags:
            if s.startswith('- '):
                tags.append(s[2:].strip())
            elif s and not s.startswith('-'):
                break
    return tags


def extract_links(content: str) -> list[str]:
    """Wiki-link targets, anchors stripped, media filtered out."""
    out = []
    for raw in LINK_RE.findall(content):
        target = raw.split('#')[0].split('|')[0].strip()
        if not target:
            continue
        if target.lower().endswith(MEDIA_EXTS):
            continue
        out.append(target)
    return out


def main():
    md_files = sorted(VAULT_DIR.glob("*.md"))
    print(f"Vault: {len(md_files)} notes in {VAULT_DIR}")

    titles = {f.stem for f in md_files}

    notes_data = {}     # title -> dict
    edge_set = set()    # frozenset({a, b}) — undirected, dedup

    for md in md_files:
        title = md.stem
        content = md.read_text(encoding='utf-8')

        tags = extract_tags(content)
        links_raw = extract_links(content)

        # Only keep links that resolve to actual note titles
        valid_links = [t for t in links_raw if t in titles and t != title]

        # Add to undirected edge set
        for tgt in valid_links:
            edge_set.add(frozenset((title, tgt)))

        notes_data[title] = {
            'title': title,
            'filename': md.name,
            'tags': tags,
            'outgoing_links': valid_links,
            'char_count': len(content),
        }

    # Compute degree from edge set (undirected)
    degree = Counter()
    for e in edge_set:
        a, b = list(e)
        degree[a] += 1
        degree[b] += 1

    # Attach degree to each note
    for title, data in notes_data.items():
        data['degree'] = degree.get(title, 0)

    # Sort by degree desc for output
    nodes_sorted = sorted(notes_data.values(), key=lambda d: -d['degree'])

    # Build edge list as list of dicts (sorted pair for stability)
    edges = []
    for e in edge_set:
        pair = sorted(list(e))
        edges.append({'a': pair[0], 'b': pair[1]})
    edges.sort(key=lambda d: (d['a'], d['b']))

    out = {
        'meta': {
            'vault': str(VAULT_DIR),
            'note_count': len(nodes_sorted),
            'edge_count': len(edges),
            'directionality': 'undirected',
            'media_filtered_extensions': list(MEDIA_EXTS),
        },
        'nodes': nodes_sorted,
        'edges': edges,
    }

    OUT.write_text(json.dumps(out, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f"\nSaved: {OUT}")
    print(f"Nodes: {len(nodes_sorted)}")
    print(f"Edges: {len(edges)} (undirected, deduped)")
    print(f"\nTop 10 by degree:")
    for n in nodes_sorted[:10]:
        print(f"  {n['degree']:>3}  {n['title']}")
    print(f"\nDegree distribution:")
    deg_counts = Counter(n['degree'] for n in nodes_sorted)
    print(f"  isolated (deg 0): {deg_counts[0]}")
    print(f"  leaf (1-2):       {sum(c for d, c in deg_counts.items() if 1 <= d <= 2)}")
    print(f"  medium (3-9):     {sum(c for d, c in deg_counts.items() if 3 <= d <= 9)}")
    print(f"  hub (>=10):       {sum(c for d, c in deg_counts.items() if d >= 10)}")


if __name__ == '__main__':
    main()
