#!/usr/bin/env python3
"""Digest agent: analyzes proving session traces and produces structured lessons."""

import argparse
import json
import os
import sys
from pathlib import Path


def load_prompt_template() -> str:
    template_path = Path(__file__).parent / "prompt_template.txt"
    with open(template_path) as f:
        return f.read()


def load_trace(trace_path: str) -> str:
    path = Path(trace_path)
    if path.suffix == ".json":
        with open(path) as f:
            data = json.load(f)
        return json.dumps(data, indent=2)
    else:
        # Plain text / markdown trace
        with open(path) as f:
            return f.read()


def call_llm(prompt: str) -> str:
    """Call an LLM API to generate the digest. Tries Anthropic first, then OpenAI."""
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if api_key:
        return _call_anthropic(prompt, api_key)

    api_key = os.environ.get("OPENAI_API_KEY")
    if api_key:
        return _call_openai(prompt, api_key)

    print("ERROR: Set ANTHROPIC_API_KEY or OPENAI_API_KEY", file=sys.stderr)
    sys.exit(1)


def _call_anthropic(prompt: str, api_key: str) -> str:
    import anthropic

    client = anthropic.Anthropic(api_key=api_key)
    response = client.messages.create(
        model="claude-sonnet-4-20250514",
        max_tokens=4096,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


def _call_openai(prompt: str, api_key: str) -> str:
    import openai

    client = openai.OpenAI(api_key=api_key)
    response = client.chat.completions.create(
        model="gpt-4o",
        max_tokens=4096,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.choices[0].message.content


def main():
    parser = argparse.ArgumentParser(description="Analyze proving traces and extract lessons")
    parser.add_argument("--trace", required=True, help="Path to the trace file (JSON or text)")
    parser.add_argument("--output", default="digests/", help="Output directory for digest files")
    args = parser.parse_args()

    template = load_prompt_template()
    trace = load_trace(args.trace)
    prompt = template.replace("{trace}", trace)

    print(f"Analyzing trace: {args.trace}", file=sys.stderr)
    digest = call_llm(prompt)

    # Write output
    output_dir = Path(args.output)
    output_dir.mkdir(parents=True, exist_ok=True)

    trace_name = Path(args.trace).stem
    output_path = output_dir / f"{trace_name}_digest.md"

    with open(output_path, "w") as f:
        f.write(digest)

    print(f"Digest written to: {output_path}", file=sys.stderr)
    print(digest)


if __name__ == "__main__":
    main()
