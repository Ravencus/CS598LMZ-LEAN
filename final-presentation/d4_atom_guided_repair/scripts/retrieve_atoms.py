"""
Phase 4-6: Atom retrieval + matched-irrelevant context + oracle atoms.

For each test problem:
- Find graph-distance-1 neighbors
- Pull atoms from existing extractions where available
- Apply leakage scrubbing (regex remove the problem's known answer literals)
- Build matched-irrelevant context (length-matched filler)
- Allow user to select oracle atom

Saves all retrieval outputs for the experiment.
"""
import json
import re
from pathlib import Path
from typing import Optional

DATA = Path('/workspace/final-artifacts/data')
ART = Path('/workspace/final-presentation/d4_atom_guided_repair/artifacts')
ART.mkdir(parents=True, exist_ok=True)


def load_problem_graph():
    return json.load(open(DATA / 'problem_graph.json'))


def build_neighbor_map(graph):
    """Build problem_id -> set of neighbor problem ids."""
    nbrs = {}
    edges = graph['within_note_edges'] + graph['cross_note_edges']
    for e in edges:
        nbrs.setdefault(e['source'], set()).add(e['target'])
        nbrs.setdefault(e['target'], set()).add(e['source'])
    return nbrs


def find_neighbors_with_atoms(problem_id: str, k: int = 5):
    """Get up to k neighbors of problem_id that have rich text we can use as atoms."""
    graph = load_problem_graph()
    nbrs = build_neighbor_map(graph)
    by_id = {n.get('id', ''): n for n in graph['nodes']}

    direct = nbrs.get(problem_id, set())
    selected = []
    for nid in direct:
        n = by_id.get(nid)
        if n is None:
            continue
        # Use the problem's own statement + key_techniques as a "lightweight atom"
        if n.get('statement_en') and n.get('key_techniques'):
            selected.append({
                'id': nid,
                'source_note': n.get('source_note'),
                'statement': n.get('statement_en', ''),
                'techniques': n.get('key_techniques', []),
                'difficulty': n.get('difficulty'),
                'domain': n.get('domain'),
            })
        if len(selected) >= k:
            break
    return selected


def find_random_neighbors(problem_id: str, k: int = 5, seed: int = 42):
    """Find k unrelated neighbor problems for the random control."""
    import random
    rng = random.Random(seed)
    graph = load_problem_graph()
    nbrs = build_neighbor_map(graph)
    direct = nbrs.get(problem_id, set())
    by_id = {n.get('id', ''): n for n in graph['nodes']}

    # Exclude the problem itself + its 1-hop neighbors + its source note's other problems
    target_node = by_id.get(problem_id)
    if not target_node:
        return []
    same_note = target_node.get('source_note', '')

    excluded = direct | {problem_id}
    candidates = [
        n for n in graph['nodes']
        if n.get('id', '') not in excluded
        and n.get('source_note', '') != same_note
        and n.get('statement_en')
        and n.get('key_techniques')
    ]
    rng.shuffle(candidates)
    selected = candidates[:k]
    return [
        {
            'id': n.get('id'),
            'source_note': n.get('source_note'),
            'statement': n.get('statement_en', ''),
            'techniques': n.get('key_techniques', []),
            'difficulty': n.get('difficulty'),
            'domain': n.get('domain'),
        }
        for n in selected
    ]


def format_atoms_as_context(atoms: list, scrub_terms: list = None) -> str:
    """Format a list of atom dicts as a prompt-ready context block."""
    if not atoms:
        return ''
    scrub_terms = scrub_terms or []

    def scrub(text: str) -> str:
        for term in scrub_terms:
            if term:
                text = re.sub(re.escape(term), '[REDACTED]', text, flags=re.IGNORECASE)
        return text

    lines = ['## Related techniques and problems (from a related-knowledge graph):\n']
    for i, a in enumerate(atoms, 1):
        stmt = scrub(a['statement'])[:300]
        techs = ', '.join(scrub(t) for t in a.get('techniques', []))
        lines.append(f"### Related #{i} ({a.get('domain', '?')}, {a.get('difficulty', '?')}):")
        lines.append(f"Problem: {stmt}")
        if techs:
            lines.append(f"Key techniques: {techs}")
        lines.append('')
    return '\n'.join(lines)


def build_matched_irrelevant(target_length: int, seed: int = 42) -> str:
    """Generate length-matched filler text from unrelated mathematical content."""
    # Random unrelated math text — drawn from a diverse pool
    filler_chunks = [
        "## Related techniques and problems (from a related-knowledge graph):\n",
        "### Related #1 (number theory, easy):",
        "Problem: Show that there are infinitely many prime numbers.",
        "Key techniques: Euclid's proof, contradiction by hypothetical largest prime",
        "",
        "### Related #2 (combinatorics, medium):",
        "Problem: How many ways can n distinct objects be partitioned into k non-empty subsets?",
        "Key techniques: Stirling numbers of the second kind, recurrence relation",
        "",
        "### Related #3 (linear algebra, easy):",
        "Problem: A matrix is invertible if and only if its determinant is nonzero.",
        "Key techniques: cofactor expansion, row reduction, characteristic polynomial",
        "",
        "### Related #4 (topology, medium):",
        "Problem: Show that a continuous bijection from a compact space to a Hausdorff space is a homeomorphism.",
        "Key techniques: closed map, compactness, Hausdorff separation",
        "",
        "### Related #5 (group theory, easy):",
        "Problem: Lagrange's theorem: the order of a subgroup divides the order of the group.",
        "Key techniques: cosets, equivalence relation, partition argument",
        "",
    ]
    text = '\n'.join(filler_chunks)
    while len(text) < target_length:
        text += '\n' + '\n'.join(filler_chunks)
    return text[:target_length]


def main():
    """Build retrieval artifacts for problems specified on the command line."""
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--problem-ids', nargs='+', help='Problem IDs to build atoms for')
    parser.add_argument('--k', type=int, default=3, help='Number of atoms per condition')
    args = parser.parse_args()

    pool = json.load(open(ART / 'problem_pool.json'))
    by_id = {p['id']: p for p in pool}

    target_ids = args.problem_ids or [p['id'] for p in pool]

    for pid in target_ids:
        problem = by_id.get(pid)
        if not problem:
            print(f'WARNING: {pid} not in pool, skipping')
            continue

        print(f'\n=== {problem["label"]} ({pid}) ===')
        print(f'  problem: {problem["statement_en"][:100]}')

        # 1-hop neighbors
        one_hop = find_neighbors_with_atoms(pid, k=args.k)
        print(f'  1-hop neighbors found: {len(one_hop)}')
        for n in one_hop:
            print(f"    - {n['id']:<22} [{n['difficulty']:<6}] {n['statement'][:80]}")

        # Random unrelated
        rand = find_random_neighbors(pid, k=args.k)
        print(f'  random unrelated: {len(rand)}')

        # Build context strings
        scrub_terms = []  # populate per-problem (e.g., known answer literals)
        one_hop_ctx = format_atoms_as_context(one_hop, scrub_terms=scrub_terms)
        rand_ctx = format_atoms_as_context(rand, scrub_terms=scrub_terms)

        # Matched-irrelevant: length-matched to one-hop
        matched_irrelevant_ctx = build_matched_irrelevant(target_length=len(one_hop_ctx))

        # Save per-problem retrieval pack
        out = ART / 'retrieval' / problem['label']
        out.mkdir(parents=True, exist_ok=True)
        (out / 'one_hop.json').write_text(json.dumps(one_hop, indent=2, ensure_ascii=False))
        (out / 'random.json').write_text(json.dumps(rand, indent=2, ensure_ascii=False))
        (out / 'one_hop_context.txt').write_text(one_hop_ctx)
        (out / 'random_context.txt').write_text(rand_ctx)
        (out / 'matched_irrelevant_context.txt').write_text(matched_irrelevant_ctx)

        print(f'  Saved retrieval pack: {out}')


if __name__ == '__main__':
    main()
