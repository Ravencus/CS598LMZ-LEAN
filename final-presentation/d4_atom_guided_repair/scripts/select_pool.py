"""
Phase 1: Select and pre-register the candidate problem pool.
Picks 8 problems from D2 dataset matching criteria, saves as artifacts/problem_pool.json.
This file is locked in BEFORE screening.
"""
import json
from pathlib import Path

DATA = Path('/workspace/final-artifacts/data')
OUT = Path('/workspace/final-presentation/d4_atom_guided_repair/artifacts')
OUT.mkdir(parents=True, exist_ok=True)


def main():
    problem_graph = json.load(open(DATA / 'problem_graph.json'))
    nodes = problem_graph['nodes']
    edges = problem_graph['within_note_edges'] + problem_graph['cross_note_edges']

    # neighbor count per problem
    nbrs = {}
    for e in edges:
        nbrs.setdefault(e['source'], set()).add(e['target'])
        nbrs.setdefault(e['target'], set()).add(e['source'])

    # 8 hand-picked problems (verified to exist in the graph)
    target_ids = [
        ('SumInt13',     'sum-int-13'),       # convex H_n improvement -> H_n >= (n+1)/(2n) + log n
        ('Termwise3',    'termwise-3'),       # 1+1/2!+...+1/N! < 3
        ('PowerMeanLim', 'termwise-13'),      # lim_{p->inf} weighted power mean = max
        ('SumIntP',      'sum-int-9'),        # T_N=sum a_n/S_n^p bounded for p>1
        ('SumInt7',      'sum-int-7'),        # sum (x_k-x_{k-1})(1-x_k) < 1/2
        ('LogKn2',       'termwise-18'),      # lim sum log(1+k/n^2)
        ('JNLog',        'termwise-27'),      # lim of n|nJ_n - 1| where J_n=int log(1+x/n)/x
        ('SumInt10',     'sum-int-10'),       # estimate sum 1/(n+sqrt(i)) = 1 - 2/(3 sqrt n) + o(1/sqrt n)
    ]

    pool = []
    by_id = {n.get('id', ''): n for n in nodes}
    for label, tid in target_ids:
        n = by_id.get(tid)
        if n is None:
            print(f'  WARNING: {tid} not found, skipping')
            continue
        pool.append({
            'label': label,
            'id': n.get('id'),
            'type': n.get('type'),
            'difficulty': n.get('difficulty'),
            'domain': n.get('domain'),
            'source_note': n.get('source_note'),
            'statement_en': n.get('statement_en', ''),
            'key_techniques': n.get('key_techniques', []),
            'n_neighbors': len(nbrs.get(n.get('id', ''), set())),
        })

    print(f'Selected {len(pool)} problems for pool')
    for p in pool:
        print(f"  [{p['label']:<12}] {p['difficulty']:<6} {p['domain']:<25} ({p['n_neighbors']:>2} nbrs) {p['statement_en'][:75]}")

    # Save the pool — this LOCKS IN our pre-registration
    out_path = OUT / 'problem_pool.json'
    with open(out_path, 'w') as f:
        json.dump(pool, f, indent=2, ensure_ascii=False)
    print(f'\nPool saved to {out_path}')
    return pool


if __name__ == '__main__':
    main()
