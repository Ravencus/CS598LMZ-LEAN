"""
Stage 1.5: Translate all note titles to English.

Reads the note-level graph and adds an `english_title` field to every node.
The note graph remains the canonical persistent artifact — everything downstream
references the english_title from there.

Strategy: batch all 455 titles in a single Codex call (gpt-5.4). The prompt
asks for a JSON object mapping {original_title: english_title}.

If the call fails or skips some titles, we run again only for the missing ones.
"""

import json
import re
import subprocess
import tempfile
import os
import sys
from pathlib import Path

GRAPH = Path("/workspace/final-presentation/d2_curation_v2/data/note_graph.json")

PROMPT_TEMPLATE = """You are translating Chinese mathematics note titles to English.

For each input title, produce a concise English translation that:
- Keeps mathematical names as-is (e.g., "Cauchy-Schwarz", "Borel-Cantelli", "Riemann")
- Uses standard English mathematical terminology
- Keeps the title short (under 80 characters)
- Does NOT include Chinese characters

Output a single JSON object mapping each input title to its English translation:
{{
  "<original title 1>": "<english translation 1>",
  "<original title 2>": "<english translation 2>",
  ...
}}

Output ONLY the JSON object, no surrounding prose.

Input titles ({n} total):
{titles_json}
"""


def codex_call(prompt: str, model: str = "gpt-5.4", timeout: int = 600) -> str | None:
    with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
        out_file = f.name
    try:
        result = subprocess.run(
            ["codex", "exec", "-c", f'model="{model}"', "-o", out_file, prompt],
            capture_output=True, text=True, timeout=timeout,
        )
        if result.returncode == 0 and Path(out_file).exists():
            return Path(out_file).read_text(encoding='utf-8').strip()
        return None
    except subprocess.TimeoutExpired:
        print("  [TIMEOUT]", file=sys.stderr)
        return None
    finally:
        try: os.unlink(out_file)
        except Exception: pass


def parse_json_obj(text: str):
    if not text:
        return None
    fenced = re.search(r'```(?:json)?\s*\n(.*?)\n```', text, re.DOTALL)
    if fenced:
        text = fenced.group(1)
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    # Find the outermost {...}
    start = text.find('{')
    end = text.rfind('}')
    if start >= 0 and end > start:
        try:
            return json.loads(text[start:end+1])
        except json.JSONDecodeError:
            pass
    return None


def main():
    graph = json.loads(GRAPH.read_text(encoding='utf-8'))
    nodes = graph['nodes']
    print(f"Note graph: {len(nodes)} nodes")

    # Find titles that still need translation
    untranslated = [n['title'] for n in nodes if not n.get('english_title')]
    print(f"Titles needing translation: {len(untranslated)}")

    if not untranslated:
        print("All titles already translated.")
        return

    # Batch all in one call (titles are short)
    BATCH_SIZE = 200
    translations = {}

    for i in range(0, len(untranslated), BATCH_SIZE):
        batch = untranslated[i:i+BATCH_SIZE]
        print(f"  Batch {i//BATCH_SIZE + 1}: requesting {len(batch)} translations...")
        prompt = PROMPT_TEMPLATE.format(
            n=len(batch),
            titles_json=json.dumps(batch, ensure_ascii=False, indent=2),
        )
        response = codex_call(prompt)
        if response is None:
            print(f"  Codex call failed for batch {i//BATCH_SIZE + 1}")
            continue
        parsed = parse_json_obj(response)
        if parsed is None:
            print(f"  JSON parse failed for batch {i//BATCH_SIZE + 1}")
            print(f"  raw response: {response[:300]}")
            continue
        translations.update(parsed)
        print(f"  Batch {i//BATCH_SIZE + 1}: got {len(parsed)} translations")

    # Apply translations
    applied = 0
    missing = []
    cjk_re = re.compile(r'[一-鿿]')
    for n in nodes:
        if n.get('english_title'):
            continue
        title = n['title']
        en = translations.get(title, '').strip() if title in translations else ''
        if not en:
            missing.append(title)
            continue
        if cjk_re.search(en):
            print(f"  WARNING: translation still contains Chinese: '{title}' -> '{en}' (kept)")
        n['english_title'] = en
        applied += 1

    print(f"\nApplied translations: {applied}")
    print(f"Still missing: {len(missing)}")
    if missing[:5]:
        print(f"Examples missing: {missing[:5]}")

    # Save
    GRAPH.write_text(json.dumps(graph, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f"\nUpdated: {GRAPH}")


if __name__ == '__main__':
    main()
