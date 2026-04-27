#!/usr/bin/env python3
"""
Weak-Model Transfer Test
Tests whether knowledge atoms from a strong model help a weak model solve problems.
"""

import json
import os
import sys
import time
import argparse
from pathlib import Path


PROBLEMS = [
    {
        "id": "complex_subset_sum_optimal",
        "statement": """Given n complex numbers z_1, ..., z_n with sum of |z_k| = 1,
prove that there exists a subset S such that |sum_{k in S} z_k| >= 1/pi.
What is the key technique and why is 1/pi optimal?""",
        "expected_keyword": "averaging",  # The averaging/rotation argument
        "difficulty": "hard",
    },
    {
        "id": "borel_cantelli_application",
        "statement": """Let X_1, X_2, ... be independent random variables with P(|X_n| > n) = 1/n^2.
Prove that X_n/n -> 0 almost surely.""",
        "expected_keyword": "borel-cantelli",
        "difficulty": "medium",
    },
    {
        "id": "series_convergence",
        "statement": """Prove that the series sum_{n=1}^{infinity} sin(n)/n converges.
What technique do you use and why does it work?""",
        "expected_keyword": "abel",  # Abel/Dirichlet summation
        "difficulty": "medium",
    },
]


def call_model(prompt: str, model: str, max_tokens: int = 2048) -> tuple[str, int, float]:
    """Call a specific model. Returns (response, tokens, latency)."""
    t0 = time.time()

    # Determine provider from model name
    if "claude" in model or "haiku" in model or "sonnet" in model or "opus" in model:
        import anthropic
        client = anthropic.Anthropic()
        response = client.messages.create(
            model=model, max_tokens=max_tokens,
            messages=[{"role": "user", "content": prompt}]
        )
        text = response.content[0].text
        tokens = response.usage.input_tokens + response.usage.output_tokens
    else:
        import openai
        client = openai.OpenAI()
        response = client.chat.completions.create(
            model=model, max_tokens=max_tokens,
            messages=[{"role": "user", "content": prompt}]
        )
        text = response.choices[0].message.content
        tokens = response.usage.total_tokens

    return text, tokens, time.time() - t0


def run_baseline(problem: dict, weak_model: str) -> dict:
    """Run weak model on problem with no additional context."""
    prompt = f"""Solve this mathematical problem. Show your reasoning step by step.

Problem: {problem['statement']}"""

    text, tokens, latency = call_model(prompt, weak_model)
    return {
        "condition": "baseline",
        "model": weak_model,
        "problem_id": problem["id"],
        "response": text,
        "tokens": tokens,
        "latency": latency,
        "contains_key_technique": problem["expected_keyword"].lower() in text.lower(),
    }


def run_with_atoms(problem: dict, weak_model: str, atoms_path: str) -> dict:
    """Run weak model on problem WITH knowledge atoms as context."""
    atoms_data = json.loads(Path(atoms_path).read_text(encoding='utf-8'))

    # Format atoms as context
    atoms_text = []
    for step in atoms_data.get("steps", []):
        atom = step.get("atom", {})
        atoms_text.append(f"- Trigger: {atom.get('trigger', 'N/A')}")
        atoms_text.append(f"  Action: {atom.get('action', 'N/A')}")
        atoms_text.append(f"  Outcome: {atom.get('outcome', 'N/A')}")
        atoms_text.append(f"  Boundary: {atom.get('boundary', 'N/A')}")
        atoms_text.append("")

    iks = atoms_data.get("irreducible_knowledge_set", [])
    iks_text = "\n".join(f"- {item}" for item in iks)

    prompt = f"""Solve this mathematical problem. You are provided with knowledge atoms —
transferable mathematical insights that may be relevant to this problem.

## Knowledge Atoms (from related problems)
{chr(10).join(atoms_text)}

## Irreducible Knowledge Set
{iks_text}

## Problem
{problem['statement']}

Use the knowledge atoms above if relevant. Show your reasoning step by step."""

    text, tokens, latency = call_model(prompt, weak_model)
    return {
        "condition": "with_atoms",
        "model": weak_model,
        "problem_id": problem["id"],
        "response": text,
        "tokens": tokens,
        "latency": latency,
        "contains_key_technique": problem["expected_keyword"].lower() in text.lower(),
        "atoms_file": atoms_path,
    }


def evaluate_response(result: dict, problem: dict) -> dict:
    """Simple evaluation: check for key technique mentions and reasoning quality."""
    text = result["response"].lower()
    keyword = problem["expected_keyword"].lower()

    # Check for technique mention
    technique_mentioned = keyword in text

    # Check for mathematical reasoning indicators
    has_proof_structure = any(w in text for w in ["proof", "prove", "therefore", "hence", "thus", "qed", "follows"])
    has_math_notation = any(w in text for w in ["sum", "integral", "subset", "bound", "inequality"])

    result["evaluation"] = {
        "technique_mentioned": technique_mentioned,
        "has_proof_structure": has_proof_structure,
        "has_math_notation": has_math_notation,
        "quality_score": sum([technique_mentioned, has_proof_structure, has_math_notation]),
    }
    return result


def main():
    parser = argparse.ArgumentParser(description="Weak-model transfer test")
    parser.add_argument("--weak-model", default="claude-haiku-4-5-20251001", help="Weak model to test")
    parser.add_argument("--strong-model", default="claude-sonnet-4-20250514", help="Strong model for generating atoms")
    parser.add_argument("--atoms", help="Path to pre-generated atoms JSON (skip strong model run)")
    parser.add_argument("--problem", default="complex_subset_sum_optimal", help="Problem ID")
    parser.add_argument("--output-dir", default="/workspace/final-artifacts/results/transfer")
    parser.add_argument("--dry-run", action="store_true", help="Show setup without running")
    args = parser.parse_args()

    problem = next((p for p in PROBLEMS if p["id"] == args.problem), None)
    if not problem:
        print(f"Unknown problem: {args.problem}")
        print(f"Available: {[p['id'] for p in PROBLEMS]}")
        return

    out_dir = Path(args.output_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    if args.dry_run:
        print(f"Problem: {problem['id']}")
        print(f"Statement: {problem['statement'][:200]}...")
        print(f"Expected technique: {problem['expected_keyword']}")
        print(f"Weak model: {args.weak_model}")
        print(f"Atoms: {args.atoms or 'will generate with ' + args.strong_model}")
        return

    results = []

    # Step 1: Baseline (weak model, no context)
    print(f"\n=== Baseline: {args.weak_model} on {problem['id']} ===")
    baseline = run_baseline(problem, args.weak_model)
    baseline = evaluate_response(baseline, problem)
    results.append(baseline)
    print(f"Technique mentioned: {baseline['evaluation']['technique_mentioned']}")
    print(f"Quality score: {baseline['evaluation']['quality_score']}/3")

    # Step 2: With atoms
    atoms_path = args.atoms
    if not atoms_path:
        print(f"\n=== Generating atoms with {args.strong_model} ===")
        # Generate atoms using the digest agent
        import subprocess
        trace_path = "workspace/traces/complex_subset_sum_reasoning.md"
        atoms_path = str(out_dir / f"{problem['id']}_atoms.json")
        subprocess.run([
            sys.executable, str(Path(__file__).parent / "digest_atoms.py"),
            "--trace", trace_path,
            "--output-dir", str(out_dir),
            "--model", args.strong_model,
        ], check=True)
        # Find the generated atoms file
        for f in out_dir.glob("*_atoms.json"):
            atoms_path = str(f)
            break

    print(f"\n=== With atoms: {args.weak_model} on {problem['id']} ===")
    with_atoms = run_with_atoms(problem, args.weak_model, atoms_path)
    with_atoms = evaluate_response(with_atoms, problem)
    results.append(with_atoms)
    print(f"Technique mentioned: {with_atoms['evaluation']['technique_mentioned']}")
    print(f"Quality score: {with_atoms['evaluation']['quality_score']}/3")

    # Step 3: Compare
    print(f"\n=== Comparison ===")
    print(f"{'Condition':<20} {'Technique?':<12} {'Quality':<10} {'Tokens':<10}")
    print("-" * 55)
    for r in results:
        print(f"{r['condition']:<20} {'Y' if r['evaluation']['technique_mentioned'] else 'N':<12} {r['evaluation']['quality_score']}/3{'':<5} {r['tokens']:<10}")

    # Save results
    output_path = out_dir / f"transfer_test_{problem['id']}.json"
    with open(output_path, 'w') as f:
        json.dump(results, f, indent=2)
    print(f"\nResults saved to {output_path}")


if __name__ == "__main__":
    main()
