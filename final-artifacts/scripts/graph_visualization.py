"""
Graph Visualization for Dataset Curation
Generates presentation-ready figures from the vault metadata and problem graph.
"""

import json
import argparse
from pathlib import Path
from collections import Counter
import matplotlib.pyplot as plt
import matplotlib
import numpy as np

matplotlib.rcParams['font.family'] = ['DejaVu Sans', 'sans-serif']
matplotlib.rcParams['figure.dpi'] = 150

DATA_DIR = Path("/workspace/final-artifacts/data")
FIG_DIR = Path("/workspace/final-artifacts/figures")


def load_metadata():
    return json.load(open(DATA_DIR / "vault_metadata.json"))


def load_edges():
    return json.load(open(DATA_DIR / "vault_edges.json"))


def fig_subgraph_stats(metadata: list, subgraph_titles: list[str]):
    """Generate statistics comparison: full vault vs selected subgraph."""
    sub_notes = [n for n in metadata if n["title"] in set(subgraph_titles)]

    fig, axes = plt.subplots(1, 2, figsize=(12, 5))

    # Left: tier breakdown comparison
    full_tiers = Counter(n["tier"] for n in metadata)
    sub_tiers = Counter(n["tier"] for n in sub_notes)
    tiers = ["hub", "medium", "leaf", "isolated"]
    colors = ['#C44E52', '#DD8452', '#4C72B0', '#CCCCCC']

    x = np.arange(len(tiers))
    w = 0.35
    axes[0].bar(x - w/2, [full_tiers.get(t, 0) / len(metadata) * 100 for t in tiers], w, label=f'Full vault (n={len(metadata)})', color=colors, alpha=0.6)
    axes[0].bar(x + w/2, [sub_tiers.get(t, 0) / len(sub_notes) * 100 for t in tiers] if sub_notes else [0]*4, w, label=f'Subgraph (n={len(sub_notes)})', color=colors, edgecolor='black', linewidth=1.5)
    axes[0].set_xticks(x)
    axes[0].set_xticklabels(['Hub\n(deg≥10)', 'Medium\n(3-9)', 'Leaf\n(1-2)', 'Isolated\n(0)'])
    axes[0].set_ylabel('Percentage of nodes')
    axes[0].set_title('Tier Distribution: Full Vault vs Subgraph', fontweight='bold')
    axes[0].legend()

    # Right: domain diversity
    full_tags = Counter()
    sub_tags = Counter()
    skip_tags = {'math'}  # skip the universal tag
    for n in metadata:
        for t in n["tags"]:
            if t not in skip_tags:
                full_tags[t] += 1
    for n in sub_notes:
        for t in n["tags"]:
            if t not in skip_tags:
                sub_tags[t] += 1

    top_tags = [t for t, _ in full_tags.most_common(10)]
    x = np.arange(len(top_tags))
    axes[1].barh(x, [full_tags[t] for t in top_tags], height=0.4, label='Full vault', alpha=0.5, color='#4C72B0')
    axes[1].barh(x + 0.4, [sub_tags.get(t, 0) for t in top_tags], height=0.4, label='Subgraph', color='#C44E52')
    axes[1].set_yticks(x + 0.2)
    axes[1].set_yticklabels(top_tags, fontsize=8)
    axes[1].invert_yaxis()
    axes[1].set_xlabel('Note count')
    axes[1].set_title('Domain Coverage', fontweight='bold')
    axes[1].legend(fontsize=8)

    plt.tight_layout()
    plt.savefig(FIG_DIR / 'subgraph_stats.png', bbox_inches='tight')
    print(f"Saved: {FIG_DIR / 'subgraph_stats.png'}")
    plt.close()


def fig_hub_fanout(metadata: list, edges: list, hub_title: str):
    """Show how a hub connects to many problems."""
    # Find neighbors
    neighbors = set()
    for e in edges:
        if e["source"] == hub_title:
            neighbors.add(e["target"])
        if e["target"] == hub_title:
            neighbors.add(e["source"])

    existing = set(n["title"] for n in metadata)
    valid = [n for n in neighbors if n in existing]
    degree_map = {n["title"]: n["in_degree"] for n in metadata}

    # Sort by degree
    valid.sort(key=lambda x: degree_map.get(x, 0), reverse=True)
    top = valid[:15]

    fig, ax = plt.subplots(figsize=(10, 6))

    # Draw hub in center
    hub_y = len(top) / 2
    ax.scatter([0], [hub_y], s=500, c='#C44E52', zorder=5)
    ax.annotate(hub_title[:20], (0, hub_y), fontsize=9, fontweight='bold',
                ha='center', va='bottom', xytext=(0, 10), textcoords='offset points')

    # Draw neighbors
    for i, name in enumerate(top):
        deg = degree_map.get(name, 0)
        ax.scatter([1], [i], s=max(50, deg * 15), c='#4C72B0', zorder=4)
        ax.plot([0, 1], [hub_y, i], color='gray', alpha=0.3, linewidth=1)
        short_name = name[:30] + ('...' if len(name) > 30 else '')
        ax.annotate(f'{short_name} (deg={deg})', (1, i), fontsize=7,
                    ha='left', va='center', xytext=(10, 0), textcoords='offset points')

    ax.set_xlim(-0.5, 3)
    ax.set_ylim(-1, len(top))
    ax.set_title(f'Hub Fan-out: {hub_title}', fontsize=13, fontweight='bold')
    ax.axis('off')

    plt.tight_layout()
    plt.savefig(FIG_DIR / 'hub_fanout.png', bbox_inches='tight')
    print(f"Saved: {FIG_DIR / 'hub_fanout.png'}")
    plt.close()


def fig_degree_comparison(metadata: list):
    """Degree distribution of the vault."""
    in_degrees = sorted([n["in_degree"] for n in metadata], reverse=True)

    fig, ax = plt.subplots(figsize=(8, 5))
    ranks = np.arange(1, len(in_degrees) + 1)
    ax.plot(ranks, in_degrees, color='#C44E52', linewidth=2)
    ax.fill_between(ranks, in_degrees, alpha=0.15, color='#C44E52')
    ax.set_xlabel('Node rank', fontsize=12)
    ax.set_ylabel('In-degree', fontsize=12)
    ax.set_title('Knowledge Graph: Power-Law Degree Distribution', fontsize=13, fontweight='bold')
    ax.set_yscale('log')
    ax.set_xscale('log')

    # Annotate top 3
    top3 = sorted(metadata, key=lambda x: x["in_degree"], reverse=True)[:3]
    for i, n in enumerate(top3):
        ax.annotate(f'{n["title"][:20]} ({n["in_degree"]})',
                     xy=(i + 1, n["in_degree"]),
                     xytext=(i + 1 + 5, n["in_degree"] * 0.6),
                     fontsize=7,
                     arrowprops=dict(arrowstyle='->', color='gray', lw=0.8))

    plt.tight_layout()
    plt.savefig(FIG_DIR / 'degree_distribution_new.png', bbox_inches='tight')
    print(f"Saved: {FIG_DIR / 'degree_distribution_new.png'}")
    plt.close()


def main():
    parser = argparse.ArgumentParser(description="Generate graph visualizations")
    parser.add_argument("--subgraph-manifest", default=str(DATA_DIR / "codex_extraction" / "batch_manifest.json"))
    args = parser.parse_args()

    FIG_DIR.mkdir(parents=True, exist_ok=True)

    metadata = load_metadata()
    edges = load_edges()

    # Load subgraph titles from manifest
    manifest = json.load(open(args.subgraph_manifest))
    subgraph_titles = [t["title"] for t in manifest]

    print(f"Full vault: {len(metadata)} notes")
    print(f"Subgraph: {len(subgraph_titles)} notes")

    fig_subgraph_stats(metadata, subgraph_titles)
    fig_hub_fanout(metadata, edges, "逐项估计")
    fig_degree_comparison(metadata)

    print("\nAll figures saved to", FIG_DIR)


if __name__ == "__main__":
    main()
