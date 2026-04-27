#!/usr/bin/env python3
"""
Digest Agent (Knowledge Atoms Edition)
Decomposes proof/solution traces into structured knowledge atoms (4-tuples).
"""

import argparse
import json
import os
import re
import sys
from pathlib import Path


SCRIPT_DIR = Path(__file__).parent


def load_prompt_template() -> str:
    template_path = SCRIPT_DIR / "prompt_template_atoms.txt"
    return template_path.read_text(encoding='utf-8')


def load_fewshot_examples() -> str:
    fewshot_path = SCRIPT_DIR.parent / "fewshot" / "atoms_examples.json"
    if not fewshot_path.exists():
        return "(No few-shot examples available)"
    examples = json.loads(fewshot_path.read_text(encoding='utf-8'))
    # Format as readable text
    lines = []
    for ex in examples:
        lines.append(f"**Problem:** {ex['problem']}")
        lines.append(f"**Step {ex['step']}:** {ex['step_description']}")
        lines.append(f"```json")
        lines.append(json.dumps(ex['atom'], indent=2))
        lines.append(f"```\n")
    return "\n".join(lines)


def load_trace(trace_path: str) -> str:
    path = Path(trace_path)
    if path.suffix == ".json":
        with open(path) as f:
            data = json.load(f)
        return json.dumps(data, indent=2)
    else:
        return path.read_text(encoding='utf-8')


def call_llm(prompt: str, model: str = None) -> str:
    """Call LLM via shared utility (Codex CLI -> Anthropic -> OpenAI)."""
    from llm_call import call_llm as _shared_call
    return _shared_call(prompt, model=model, max_tokens=8192)


def extract_json_from_response(text: str) -> dict:
    """Extract JSON from LLM response (handles markdown code fences)."""
    # Try to find JSON in code fences
    json_match = re.search(r'```(?:json)?\s*\n(.*?)\n```', text, re.DOTALL)
    if json_match:
        try:
            return json.loads(json_match.group(1))
        except json.JSONDecodeError:
            pass

    # Try to parse the entire response as JSON
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass

    # Try to find any JSON object in the text
    brace_start = text.find('{')
    if brace_start >= 0:
        # Find matching closing brace
        depth = 0
        for i in range(brace_start, len(text)):
            if text[i] == '{':
                depth += 1
            elif text[i] == '}':
                depth -= 1
                if depth == 0:
                    try:
                        return json.loads(text[brace_start:i+1])
                    except json.JSONDecodeError:
                        break

    return {"raw_response": text, "parse_error": "Could not extract JSON"}


def validate_atoms(data: dict) -> dict:
    """Validate that extracted atoms have all required fields."""
    steps = data.get("steps", [])
    valid = 0
    uncertain_boundaries = 0
    for step in steps:
        atom = step.get("atom", {})
        has_all = all(k in atom for k in ["trigger", "action", "outcome", "boundary"])
        if has_all:
            valid += 1
        if "BOUNDARY UNCERTAIN" in atom.get("boundary", ""):
            uncertain_boundaries += 1

    data["validation"] = {
        "total_steps": len(steps),
        "valid_atoms": valid,
        "uncertain_boundaries": uncertain_boundaries,
    }
    return data


def format_atoms_markdown(data: dict) -> str:
    """Format knowledge atoms as readable markdown."""
    lines = ["# Knowledge Atom Extraction\n"]

    steps = data.get("steps", [])
    for step in steps:
        n = step.get("step_number", "?")
        desc = step.get("description", "")
        lines.append(f"## Step {n}: {desc}\n")

        atom = step.get("atom", {})
        lines.append(f"**Trigger:** {atom.get('trigger', 'N/A')}\n")
        lines.append(f"**Action:** {atom.get('action', 'N/A')}\n")
        lines.append(f"**Outcome:** {atom.get('outcome', 'N/A')}\n")
        lines.append(f"**Boundary:** {atom.get('boundary', 'N/A')}\n")
        lines.append("")

    iks = data.get("irreducible_knowledge_set", [])
    if iks:
        lines.append("## Irreducible Knowledge Set\n")
        for item in iks:
            lines.append(f"- {item}")
        lines.append("")

    alts = data.get("alternative_approaches", [])
    if alts:
        lines.append("## Alternative Approaches\n")
        for alt in alts:
            lines.append(f"### {alt.get('approach', 'Unknown')}")
            for atom in alt.get("different_atoms_needed", []):
                lines.append(f"- {atom}")
            lines.append("")

    validation = data.get("validation", {})
    if validation:
        lines.append("## Validation\n")
        lines.append(f"- Total steps: {validation.get('total_steps', 0)}")
        lines.append(f"- Valid atoms: {validation.get('valid_atoms', 0)}")
        lines.append(f"- Uncertain boundaries: {validation.get('uncertain_boundaries', 0)}")

    return "\n".join(lines)


def main():
    parser = argparse.ArgumentParser(description="Extract knowledge atoms from proof traces")
    parser.add_argument("--trace", required=True, help="Path to trace file")
    parser.add_argument("--output-dir", default="/workspace/final-artifacts/results/digests")
    parser.add_argument("--model", default=None, help="Override model name")
    parser.add_argument("--dry-run", action="store_true", help="Show prompt without calling LLM")
    args = parser.parse_args()

    template = load_prompt_template()
    fewshot = load_fewshot_examples()
    trace = load_trace(args.trace)

    prompt = template.replace("{fewshot_examples}", fewshot).replace("{trace}", trace)

    if args.dry_run:
        print(f"Prompt length: {len(prompt)} chars")
        print(f"Trace length: {len(trace)} chars")
        print(f"\n--- Prompt preview (first 500 chars) ---")
        print(prompt[:500])
        print(f"\n--- Prompt preview (last 500 chars) ---")
        print(prompt[-500:])
        return

    print(f"Analyzing trace: {args.trace}", file=sys.stderr)
    print(f"Prompt: {len(prompt)} chars", file=sys.stderr)

    raw_response = call_llm(prompt, model=args.model)

    # Parse and validate
    data = extract_json_from_response(raw_response)
    data = validate_atoms(data)

    # Save outputs
    output_dir = Path(args.output_dir)
    output_dir.mkdir(parents=True, exist_ok=True)
    trace_name = Path(args.trace).stem

    # JSON output
    json_path = output_dir / f"{trace_name}_atoms.json"
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, indent=2, ensure_ascii=False)
    print(f"JSON saved: {json_path}", file=sys.stderr)

    # Markdown output
    md_path = output_dir / f"{trace_name}_atoms.md"
    md_content = format_atoms_markdown(data)
    md_path.write_text(md_content, encoding='utf-8')
    print(f"Markdown saved: {md_path}", file=sys.stderr)

    # Also save raw response for debugging
    raw_path = output_dir / f"{trace_name}_raw_response.txt"
    raw_path.write_text(raw_response, encoding='utf-8')

    print(f"\n=== Summary ===")
    v = data.get("validation", {})
    print(f"Steps extracted: {v.get('total_steps', 0)}")
    print(f"Valid atoms: {v.get('valid_atoms', 0)}")
    print(f"Uncertain boundaries: {v.get('uncertain_boundaries', 0)}")
    iks = data.get("irreducible_knowledge_set", [])
    print(f"Irreducible knowledge set size: {len(iks)}")


if __name__ == "__main__":
    main()
