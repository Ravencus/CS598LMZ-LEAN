"""
Validate extracted atoms against a gold set.
Measures step-level recall, boundary quality, and IKS hub overlap.
"""

import json
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))


def load_json(path: str) -> dict:
    return json.loads(Path(path).read_text(encoding='utf-8'))


def atom_matches(gold_atom: dict, extracted_atom: dict, threshold: float = 0.3) -> bool:
    """Check if an extracted atom roughly matches a gold atom.
    Uses keyword overlap in trigger + action fields."""
    def keywords(text: str) -> set:
        return set(w.lower().strip('.,;:()[]') for w in text.split() if len(w) > 3)

    gold_kw = keywords(gold_atom.get("trigger", "") + " " + gold_atom.get("action", ""))
    ext_kw = keywords(extracted_atom.get("trigger", "") + " " + extracted_atom.get("action", ""))

    if not gold_kw:
        return False
    overlap = len(gold_kw & ext_kw) / len(gold_kw)
    return overlap >= threshold


def validate(atoms_path: str, gold_path: str):
    """Run full validation."""
    atoms_data = load_json(atoms_path)
    gold_data = load_json(gold_path)

    extracted_steps = atoms_data.get("steps", [])
    extracted_atoms = [s.get("atom", {}) for s in extracted_steps]
    gold_atoms = gold_data.get("gold_atoms", [])
    expected_hubs = gold_data.get("expected_hub_connections", [])

    print(f"=== Atom Validation Report ===\n")
    print(f"Extracted atoms: {len(extracted_atoms)}")
    print(f"Gold atoms: {len(gold_atoms)}")
    print()

    # Step-level recall: how many gold atoms are matched
    matched = []
    unmatched = []
    for i, gold in enumerate(gold_atoms):
        best_match = None
        best_overlap = 0
        for j, ext in enumerate(extracted_atoms):
            def keywords(text):
                return set(w.lower().strip('.,;:()[]') for w in text.split() if len(w) > 3)
            gold_kw = keywords(gold.get("trigger", "") + " " + gold.get("action", ""))
            ext_kw = keywords(ext.get("trigger", "") + " " + ext.get("action", ""))
            if gold_kw:
                overlap = len(gold_kw & ext_kw) / len(gold_kw)
                if overlap > best_overlap:
                    best_overlap = overlap
                    best_match = j

        if best_overlap >= 0.3:
            matched.append((i, best_match, best_overlap))
        else:
            unmatched.append((i, best_overlap))

    recall = len(matched) / len(gold_atoms) if gold_atoms else 0
    print(f"## Step-Level Recall: {len(matched)}/{len(gold_atoms)} = {recall:.0%}\n")

    for i, j, overlap in matched:
        print(f"  MATCHED gold[{i}] '{gold_atoms[i]['step']}' ↔ extracted[{j}] (overlap={overlap:.0%})")
    for i, overlap in unmatched:
        print(f"  MISSED  gold[{i}] '{gold_atoms[i]['step']}' (best overlap={overlap:.0%})")
    print()

    # Boundary quality
    concrete = 0
    uncertain = 0
    vague = 0
    for s in extracted_steps:
        boundary = s.get("atom", {}).get("boundary", "")
        if "BOUNDARY UNCERTAIN" in boundary:
            uncertain += 1
        elif len(boundary) > 50 and ("fail" in boundary.lower() or "alternative" in boundary.lower() or "does not" in boundary.lower()):
            concrete += 1
        else:
            vague += 1

    total = len(extracted_steps)
    print(f"## Boundary Quality")
    print(f"  Concrete (specific failure + alternative): {concrete}/{total} = {concrete/total:.0%}" if total else "  No atoms")
    print(f"  Uncertain (flagged): {uncertain}/{total}" if total else "")
    print(f"  Vague (short or generic): {vague}/{total}" if total else "")
    print()

    # IKS hub overlap
    iks = atoms_data.get("irreducible_knowledge_set", [])
    iks_text = " ".join(iks).lower()
    print(f"## IKS Hub Overlap")
    print(f"  Extracted IKS: {iks}")
    hub_matches = 0
    for hub in expected_hubs:
        # Check if any keyword from the hub appears in the IKS
        hub_words = set(w.lower() for w in hub.split() if len(w) > 3)
        if any(w in iks_text for w in hub_words):
            print(f"  HIT: '{hub}'")
            hub_matches += 1
        else:
            print(f"  MISS: '{hub}'")
    print(f"  Hub recall: {hub_matches}/{len(expected_hubs)}")

    # Summary
    results = {
        "step_recall": recall,
        "matched_count": len(matched),
        "gold_count": len(gold_atoms),
        "boundary_concrete": concrete,
        "boundary_uncertain": uncertain,
        "boundary_vague": vague,
        "total_atoms": total,
        "hub_recall": hub_matches / len(expected_hubs) if expected_hubs else 0,
        "hub_matched": hub_matches,
        "hub_total": len(expected_hubs),
    }
    return results


def main():
    import argparse
    parser = argparse.ArgumentParser(description="Validate extracted atoms against gold set")
    parser.add_argument("--atoms", required=True, help="Path to extracted atoms JSON")
    parser.add_argument("--gold", default="/workspace/final-artifacts/fewshot/gold_set.json")
    parser.add_argument("--output", help="Path to save results JSON")
    args = parser.parse_args()

    results = validate(args.atoms, args.gold)

    if args.output:
        with open(args.output, 'w') as f:
            json.dump(results, f, indent=2)
        print(f"\nResults saved to {args.output}")


if __name__ == "__main__":
    main()
