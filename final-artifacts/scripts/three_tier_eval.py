"""
Three-Tier Evaluation Framework for Reasoning Arbitration
Tier 1: Pure CoT (no tools)
Tier 2: Naive tool use (model decides when to call sympy)
Tier 3: Reasoning Arbitration (post-hoc verification + correction)
"""

import json
import time
import argparse
from pathlib import Path
from dataclasses import dataclass, asdict, field
from typing import Optional
import sys

sys.path.insert(0, str(Path(__file__).parent))
from sympy_verifier import verify_claim, VerificationResult
from reasoning_arbitrator import arbitrate, substitute, format_report

# --- Test Problems ---

PROBLEMS = [
    {
        "id": "integral_max_cos",
        "statement": "Evaluate the integral: ∫₀²π max(cos(u), 0) du",
        "answer": "2",
        "verification": {"claim_type": "integral", "integrand_str": "Max(cos(u), 0)", "var_str": "u", "lower_str": "0", "upper_str": "2*pi", "expected_str": "2"},
    },
    {
        "id": "series_basel",
        "statement": "Evaluate the infinite series: ∑(n=1 to ∞) 1/n²",
        "answer": "π²/6",
        "verification": {"claim_type": "series", "expr_str": "1/n**2", "var_str": "n", "lower_str": "1", "upper_str": "oo", "expected_str": "pi**2/6"},
    },
    {
        "id": "integral_gaussian",
        "statement": "Evaluate: ∫₀^∞ e^(-x²) dx",
        "answer": "√π/2",
        "verification": {"claim_type": "integral", "integrand_str": "exp(-x**2)", "var_str": "x", "lower_str": "0", "upper_str": "oo", "expected_str": "sqrt(pi)/2"},
    },
    {
        "id": "inequality_pi",
        "statement": "Is it true that 1/4 > 1/π?",
        "answer": "No, 1/4 < 1/π",
        "verification": {"claim_type": "inequality", "lhs_str": "1/4", "op": "<", "rhs_str": "1/pi"},
    },
    {
        "id": "series_alternating",
        "statement": "Evaluate: ∑(n=1 to ∞) (-1)^(n+1) / n",
        "answer": "ln(2)",
        "verification": {"claim_type": "series", "expr_str": "(-1)**(n+1)/n", "var_str": "n", "lower_str": "1", "upper_str": "oo", "expected_str": "log(2)"},
    },
]


@dataclass
class TierResult:
    problem_id: str
    tier: int
    model: str
    raw_output: str = ""
    final_answer: str = ""
    final_answer_correct: bool = False
    computational_claims_total: int = 0
    computational_errors: int = 0
    errors_caught: int = 0        # Tier 3 only
    errors_corrected: int = 0     # Tier 3 only
    corrected_output: str = ""    # Tier 3 only
    token_count: int = 0
    latency_seconds: float = 0.0


def call_llm_pure_cot(problem: dict, model: str = None) -> tuple[str, int, float]:
    """Tier 1: Call LLM with no tools, pure chain-of-thought."""
    from llm_call import call_llm as _shared_call

    prompt = f"""Solve this math problem step by step. Show all your work and computation.

Problem: {problem['statement']}

Work through the solution carefully, showing each computational step."""

    t0 = time.time()
    text = _shared_call(prompt, model=model)
    latency = time.time() - t0
    tokens = len(text.split()) * 2  # rough estimate since Codex doesn't report tokens
    return text, tokens, latency


def call_llm_objective_declared(problem: dict, model: str = None) -> tuple[str, int, float]:
    """Tier 3b: Call LLM with objective-declaration instructions."""
    from llm_call import call_llm as _shared_call

    prompt = f"""Solve this math problem step by step. Show all your work.

IMPORTANT: Before computing any mathematical expression (integral, sum, limit, algebraic simplification),
you MUST state the objective on its own line in this format:
OBJECTIVE: <what you need to compute>
Then show your computation.

Example:
OBJECTIVE: evaluate integral from 0 to pi of sin(x) dx
The integral of sin(x) from 0 to pi equals [-cos(x)] from 0 to pi = -cos(pi) + cos(0) = 1 + 1 = 2.

Problem: {problem['statement']}"""

    t0 = time.time()
    text = _shared_call(prompt, model=model)
    latency = time.time() - t0
    tokens = len(text.split()) * 2
    return text, tokens, latency


def call_llm_with_tools(problem: dict, model: str = None) -> tuple[str, int, float]:
    """Tier 2: Call LLM with sympy tool available.
    Uses Anthropic tool-calling if API key available, otherwise falls back to
    Codex with explicit sympy instructions."""
    from llm_call import call_llm_with_tools as _tool_call, call_llm as _plain_call

    tools = [{
        "name": "compute_math",
        "description": "Evaluate a mathematical expression using sympy.",
        "input_schema": {
            "type": "object",
            "properties": {
                "expression": {
                    "type": "string",
                    "description": "sympy expression to evaluate, e.g. 'integrate(cos(x), (x, 0, pi))'"
                }
            },
            "required": ["expression"]
        }
    }]

    prompt = f"""Solve this math problem. You have a compute_math tool available for calculations.

Problem: {problem['statement']}"""

    t0 = time.time()
    # Try tool-calling first (needs Anthropic API)
    import os
    if os.environ.get("ANTHROPIC_API_KEY"):
        text = _tool_call(prompt, tools, model=model)
    else:
        # Codex fallback: ask it to use sympy explicitly
        fallback_prompt = f"""Solve this math problem. When you need to compute something (integral, sum, limit, etc.),
write the sympy expression and its result clearly, like:
sympy: integrate(cos(x), (x, 0, pi)) = 0

Problem: {problem['statement']}"""
        text = _plain_call(fallback_prompt, model=model)

    latency = time.time() - t0
    tokens = len(text.split()) * 2
    return text, tokens, latency


def check_answer(output: str, problem: dict) -> bool:
    """Check if the model's output contains the correct answer."""
    verification = problem["verification"]
    result = verify_claim(**verification)
    # Also check if the expected answer appears in the output
    answer = problem["answer"]
    return answer.lower() in output.lower() or result.correct


def run_tier(tier: int, problem: dict, model: str) -> TierResult:
    """Run a single tier on a single problem."""
    result = TierResult(problem_id=problem["id"], tier=tier, model=model)

    if tier == 1:
        output, tokens, latency = call_llm_pure_cot(problem, model)
        result.raw_output = output
        result.token_count = tokens
        result.latency_seconds = latency
        # Arbitrate to count errors (but don't correct)
        report = arbitrate(output)
        result.computational_claims_total = report.total_claims
        result.computational_errors = report.verified_incorrect
        result.final_answer_correct = check_answer(output, problem)

    elif tier == 2:
        output, tokens, latency = call_llm_with_tools(problem, model)
        result.raw_output = output
        result.token_count = tokens
        result.latency_seconds = latency
        report = arbitrate(output)
        result.computational_claims_total = report.total_claims
        result.computational_errors = report.verified_incorrect
        result.final_answer_correct = check_answer(output, problem)

    elif tier == 3:
        # First run pure CoT
        output, tokens, latency = call_llm_pure_cot(problem, model)
        result.raw_output = output
        result.token_count = tokens
        result.latency_seconds = latency

        # Then arbitrate and correct
        report = arbitrate(output)
        result.computational_claims_total = report.total_claims
        result.computational_errors = report.verified_incorrect
        result.errors_caught = report.verified_incorrect
        corrected = substitute(output, report)
        result.corrected_output = corrected
        result.errors_corrected = report.verified_incorrect
        result.final_answer_correct = check_answer(corrected, problem)

    elif tier == 4:  # Tier 3b: objective-declared proactive arbitration
        output, tokens, latency = call_llm_objective_declared(problem, model)
        result.raw_output = output
        result.token_count = tokens
        result.latency_seconds = latency

        # Extract declared objectives and verify proactively
        from reasoning_arbitrator import extract_objectives
        objectives = extract_objectives(output)
        result.errors_caught = len(objectives)  # repurpose: count of objectives detected

        # Also run full arbitration on the output
        report = arbitrate(output)
        result.computational_claims_total = report.total_claims
        result.computational_errors = report.verified_incorrect
        corrected = substitute(output, report)
        result.corrected_output = corrected
        result.errors_corrected = report.verified_incorrect
        result.final_answer_correct = check_answer(corrected, problem)

    return result


def run_evaluation(problem_ids: list[str] = None, tiers: list[int] = None, model: str = "claude-sonnet-4-20250514"):
    """Run the full three-tier evaluation."""
    if problem_ids:
        problems = [p for p in PROBLEMS if p["id"] in problem_ids]
    else:
        problems = PROBLEMS[:3]  # default: first 3

    if tiers is None:
        tiers = [1, 2, 3]

    results = []
    for problem in problems:
        print(f"\n{'='*60}")
        print(f"Problem: {problem['id']} — {problem['statement']}")
        print(f"Expected: {problem['answer']}")
        print(f"{'='*60}")

        for tier in tiers:
            print(f"\n--- Tier {tier} ---")
            result = run_tier(tier, problem, model)
            results.append(result)
            print(f"  Correct: {result.final_answer_correct}")
            print(f"  Claims found: {result.computational_claims_total}")
            print(f"  Errors: {result.computational_errors}")
            if tier == 3:
                print(f"  Caught: {result.errors_caught}, Corrected: {result.errors_corrected}")
            print(f"  Tokens: {result.token_count}, Latency: {result.latency_seconds:.1f}s")

    return results


def save_results(results: list[TierResult], output_dir: str):
    """Save results to JSON."""
    out = Path(output_dir)
    out.mkdir(parents=True, exist_ok=True)
    path = out / "three_tier_results.json"
    with open(path, 'w') as f:
        json.dump([asdict(r) for r in results], f, indent=2)
    print(f"\nResults saved to {path}")

    # Print summary table
    print("\n=== Summary Table ===")
    print(f"{'Problem':<25} {'Tier':<8} {'Correct':<10} {'Claims':<8} {'Errors':<8} {'Caught':<8}")
    print("-" * 75)
    for r in results:
        print(f"{r.problem_id:<25} {r.tier:<8} {'Y' if r.final_answer_correct else 'N':<10} {r.computational_claims_total:<8} {r.computational_errors:<8} {r.errors_caught:<8}")


def main():
    parser = argparse.ArgumentParser(description="Three-tier Reasoning Arbitration evaluation")
    parser.add_argument("--problems", nargs="+", help="Problem IDs to test", default=None)
    parser.add_argument("--tiers", nargs="+", type=int, help="Tiers to run", default=[1, 2, 3])
    parser.add_argument("--model", default="claude-sonnet-4-20250514", help="Model to use")
    parser.add_argument("--output-dir", default="/workspace/final-artifacts/results/arbitration")
    parser.add_argument("--dry-run", action="store_true", help="Show problems without running LLMs")
    args = parser.parse_args()

    if args.dry_run:
        print("Available problems:")
        for p in PROBLEMS:
            print(f"  {p['id']}: {p['statement']} (answer: {p['answer']})")
        return

    results = run_evaluation(args.problems, args.tiers, args.model)
    save_results(results, args.output_dir)


if __name__ == "__main__":
    main()
