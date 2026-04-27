"""
Shared LLM call utility.
Uses Codex CLI as primary backend (already authenticated), falls back to API SDKs.
"""

import os
import subprocess
import tempfile
import json
import sys


def call_llm(prompt: str, model: str = None, max_tokens: int = 4096) -> str:
    """Call an LLM. Tries Codex CLI first, then Anthropic SDK, then OpenAI SDK."""

    # Try Codex CLI (already authenticated, no API key needed)
    result = _call_codex(prompt)
    if result is not None:
        return result

    # Fallback: Anthropic API
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if api_key:
        return _call_anthropic(prompt, api_key, model or "claude-haiku-4-5-20251001", max_tokens)

    # Fallback: OpenAI API
    api_key = os.environ.get("OPENAI_API_KEY")
    if api_key:
        return _call_openai(prompt, api_key, model or "gpt-4o-mini", max_tokens)

    print("ERROR: No LLM backend available. Install Codex CLI or set ANTHROPIC_API_KEY/OPENAI_API_KEY", file=sys.stderr)
    sys.exit(1)


def call_llm_with_tools(prompt: str, tools: list[dict], model: str = None, max_tokens: int = 2048) -> str:
    """Call LLM with tool-use capability. Requires Anthropic API for now."""
    api_key = os.environ.get("ANTHROPIC_API_KEY")
    if api_key:
        import anthropic
        client = anthropic.Anthropic(api_key=api_key)
        messages = [{"role": "user", "content": prompt}]
        full_output = []
        total_tokens = 0

        for _ in range(5):
            response = client.messages.create(
                model=model or "claude-sonnet-4-20250514",
                max_tokens=max_tokens,
                tools=tools,
                messages=messages,
            )
            total_tokens += response.usage.input_tokens + response.usage.output_tokens

            for block in response.content:
                if block.type == "text":
                    full_output.append(block.text)
                elif block.type == "tool_use":
                    expr = block.input.get("expression", "")
                    full_output.append(f"[TOOL CALL: compute_math({expr})]")
                    try:
                        import sympy
                        result = str(eval(expr, {"__builtins__": {}}, sympy.__dict__))
                    except Exception as e:
                        result = f"Error: {e}"
                    full_output.append(f"[TOOL RESULT: {result}]")
                    messages.append({"role": "assistant", "content": response.content})
                    messages.append({
                        "role": "user",
                        "content": [{"type": "tool_result", "tool_use_id": block.id, "content": result}]
                    })

            if response.stop_reason == "end_turn":
                break

        return "\n".join(full_output)

    # Fallback: Codex without tools (just ask it to compute)
    return call_llm(prompt + "\n\nNote: compute any mathematical expressions yourself and show the result.")


def _call_codex(prompt: str) -> str | None:
    """Call Codex CLI. Returns None if Codex is not available."""
    try:
        with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
            output_file = f.name

        result = subprocess.run(
            ["codex", "exec", "-o", output_file, prompt],
            capture_output=True, text=True, timeout=300
        )

        if result.returncode == 0:
            try:
                return open(output_file).read().strip()
            except FileNotFoundError:
                return None
        else:
            return None
    except FileNotFoundError:
        return None  # codex not installed
    except subprocess.TimeoutExpired:
        print("  [WARNING] Codex CLI timed out", file=sys.stderr)
        return None
    finally:
        try:
            os.unlink(output_file)
        except Exception:
            pass


def _call_anthropic(prompt: str, api_key: str, model: str, max_tokens: int) -> str:
    import anthropic
    client = anthropic.Anthropic(api_key=api_key)
    response = client.messages.create(
        model=model, max_tokens=max_tokens,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.content[0].text


def _call_openai(prompt: str, api_key: str, model: str, max_tokens: int) -> str:
    import openai
    client = openai.OpenAI(api_key=api_key)
    response = client.chat.completions.create(
        model=model, max_tokens=max_tokens,
        messages=[{"role": "user", "content": prompt}],
    )
    return response.choices[0].message.content
