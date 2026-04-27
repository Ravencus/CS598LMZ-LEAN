"""
Vault Metadata Extractor
Parses 455 Obsidian math notes for structural metadata (tags, links, headings).
Outputs structured JSON for downstream dataset curation.
"""

import re
import json
import argparse
from collections import Counter
from pathlib import Path

MATH_DIR = Path("/workspace/math-notes/笔记共享vault/math")

link_pattern = re.compile(r'\[\[([^\]]+)\]\]')
tag_pattern = re.compile(r'^\s*-\s+(.+)$', re.MULTILINE)
heading_pattern = re.compile(r'^(#{1,6})\s+(.+)$', re.MULTILINE)


def extract_frontmatter_tags(content: str) -> list[str]:
    """Extract tags from YAML frontmatter without requiring PyYAML."""
    if not content.startswith('---'):
        return []
    end = content.find('---', 3)
    if end == -1:
        return []
    frontmatter = content[3:end]
    # Find the tags section
    in_tags = False
    tags = []
    for line in frontmatter.split('\n'):
        stripped = line.strip()
        if stripped.startswith('tags:'):
            in_tags = True
            # Handle inline tags: tags: [a, b, c]
            inline = stripped[5:].strip()
            if inline.startswith('['):
                tags = [t.strip().strip('"').strip("'") for t in inline.strip('[]').split(',') if t.strip()]
                break
            continue
        if in_tags:
            if stripped.startswith('- '):
                tags.append(stripped[2:].strip())
            elif stripped and not stripped.startswith('-'):
                break  # New key, end of tags
    return tags


def extract_links(content: str) -> list[str]:
    """Extract wiki-link targets, stripping section anchors."""
    links = link_pattern.findall(content)
    targets = []
    for l in links:
        target = l.split('#')[0].strip()
        if target and not target.endswith('.png') and not target.endswith('.jpg'):
            targets.append(target)
    return targets


def extract_headings(content: str) -> list[dict]:
    """Extract heading structure."""
    headings = []
    for match in heading_pattern.finditer(content):
        level = len(match.group(1))
        text = match.group(2).strip()
        headings.append({"level": level, "text": text})
    return headings


def classify_tier(in_deg: int) -> str:
    if in_deg >= 10:
        return "hub"
    elif in_deg >= 3:
        return "medium"
    elif in_deg >= 1:
        return "leaf"
    return "isolated"


def parse_vault(math_dir: Path, limit: int = 0) -> tuple[list[dict], list[dict]]:
    """Parse all notes and return (nodes_metadata, edges)."""
    md_files = sorted(math_dir.glob("*.md"))
    if limit > 0:
        md_files = md_files[:limit]

    all_nodes = set(f.stem for f in math_dir.glob("*.md"))

    # First pass: extract per-note data and count in-degrees
    in_degree = Counter()
    notes_data = []

    for md_file in md_files:
        name = md_file.stem
        content = md_file.read_text(encoding='utf-8')

        tags = extract_frontmatter_tags(content)
        links = extract_links(content)
        headings = extract_headings(content)

        for t in links:
            in_degree[t] += 1

        notes_data.append({
            "title": name,
            "filename": md_file.name,
            "tags": tags,
            "outgoing_links": links,
            "section_count": len([h for h in headings if h["level"] <= 3]),
            "heading_count": len(headings),
            "char_count": len(content),
        })

    # Ensure all nodes have in-degree
    for n in all_nodes:
        if n not in in_degree:
            in_degree[n] = 0

    # Second pass: attach in-degree and tier
    for note in notes_data:
        note["in_degree"] = in_degree.get(note["title"], 0)
        note["out_degree"] = len(note["outgoing_links"])
        note["tier"] = classify_tier(note["in_degree"])

    # Build edges list
    edges = []
    for note in notes_data:
        for target in note["outgoing_links"]:
            edges.append({"source": note["title"], "target": target})

    return notes_data, edges


def print_summary(notes: list[dict], edges: list[dict]):
    """Print summary statistics."""
    total = len(notes)
    tiers = Counter(n["tier"] for n in notes)
    all_tags = Counter()
    for n in notes:
        for t in n["tags"]:
            all_tags[t] += 1

    print(f"\n=== Vault Metadata Summary ===")
    print(f"Total notes:  {total}")
    print(f"Total edges:  {len(edges)}")
    print(f"Tiers:  Hub={tiers['hub']}  Medium={tiers['medium']}  Leaf={tiers['leaf']}  Isolated={tiers['isolated']}")
    print(f"Unique tags:  {len(all_tags)}")
    print(f"Top 10 tags:  {all_tags.most_common(10)}")
    print(f"Top 5 hubs:")
    hubs = sorted([n for n in notes if n["tier"] == "hub"], key=lambda x: x["in_degree"], reverse=True)
    for h in hubs[:5]:
        print(f"  {h['title']}  (in={h['in_degree']}, out={h['out_degree']})")


def main():
    parser = argparse.ArgumentParser(description="Extract metadata from Obsidian math vault")
    parser.add_argument("--limit", type=int, default=0, help="Limit number of notes (0=all)")
    parser.add_argument("--output-dir", type=str, default="/workspace/final-artifacts/data", help="Output directory")
    args = parser.parse_args()

    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    print(f"Parsing vault at {MATH_DIR}...")
    notes, edges = parse_vault(MATH_DIR, limit=args.limit)

    meta_path = out_dir / "vault_metadata.json"
    edges_path = out_dir / "vault_edges.json"

    with open(meta_path, 'w', encoding='utf-8') as f:
        json.dump(notes, f, ensure_ascii=False, indent=2)
    print(f"Wrote {len(notes)} notes to {meta_path}")

    with open(edges_path, 'w', encoding='utf-8') as f:
        json.dump(edges, f, ensure_ascii=False, indent=2)
    print(f"Wrote {len(edges)} edges to {edges_path}")

    print_summary(notes, edges)


if __name__ == "__main__":
    main()
