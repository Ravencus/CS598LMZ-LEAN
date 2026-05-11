"""
Stage 3b: Per-callout LLM classification using Codex CLI (gpt-5.4).

For each callout block:
- Classify as problem / definition / strategy_template / remark
- Translate title to English
- If problem: extract structured metadata (statement_en, type, difficulty, domain, key_techniques, prerequisites)
- If strategy_template: extract strategy_name_en, summary_en, applicability

Batches per-note: feeds all callouts from a single note in one Codex call.
The model sees the note title for context.
"""

import json
import re
import subprocess
import tempfile
import os
import sys
from pathlib import Path

CALLOUTS_DIR = Path("/workspace/final-presentation/d2_curation_v2/data/callouts")
OUT_DIR = Path("/workspace/final-presentation/d2_curation_v2/data/classified")
OUT_DIR.mkdir(parents=True, exist_ok=True)

CLASSIFY_PROMPT_TEMPLATE = """You are a mathematics knowledge classification agent. Below is a list of callout blocks extracted from a single math note (originally in Chinese). Classify each callout and extract structured metadata.

Note title (original): {note_title}

For EACH callout, output a JSON object:
{{
  "id": "<the callout id from input, copy verbatim>",
  "classification": "problem" | "definition" | "strategy_template" | "remark",
  "english_title": "<English version of the callout's title; translate if Chinese, keep mathematical names like Cauchy-Schwarz>",
  "if_problem": null OR {{
    "statement_en": "<English problem statement; keep mathematical notation in LaTeX intact>",
    "problem_type": "theorem" | "lemma" | "exercise" | "example" | "counterexample",
    "difficulty": "easy" | "medium" | "hard",
    "domain": "<English math domain like real analysis, number theory, etc>",
    "key_techniques": ["...", "..."],
    "prerequisites": ["...", "..."]
  }},
  "if_strategy_template": null OR {{
    "strategy_name_en": "<English name>",
    "summary_en": "<1-2 sentences in English>",
    "applicability": "<when this strategy applies, in English>"
  }}
}}

Classification rules:
- "problem": a theorem, lemma, exercise, example, or counterexample with a definite mathematical claim. Set if_problem; if_strategy_template = null.
- "strategy_template": describes a generic strategy/method/technique applicable to many problems (like "epsilon of room" or "termwise estimation"). Set if_strategy_template; if_problem = null.
- "definition": introduces a definition. Both if_* are null.
- "remark": side commentary, motivation, history, or content that doesn't fit the others. Both if_* are null.

If the title is empty, leave english_title as "".
NEVER mix Chinese characters into the english_title or any English-named field. The statement_en should also be in English (translate if needed).

Output a JSON ARRAY of objects (one per callout, in the same order).
Output ONLY the JSON array; no surrounding prose.

Callouts to classify:

{callouts_json}
"""


def codex_call(prompt: str, model: str = "gpt-5.4", timeout: int = 300) -> str | None:
    """Run codex exec and return output text."""
    with tempfile.NamedTemporaryFile(mode='w', suffix='.txt', delete=False) as f:
        out_file = f.name
    try:
        result = subprocess.run(
            ["codex", "exec", "-c", f'model="{model}"', "-o", out_file, prompt],
            capture_output=True, text=True, timeout=timeout,
        )
        if result.returncode == 0 and Path(out_file).exists():
            return Path(out_file).read_text(encoding='utf-8').strip()
        else:
            print(f"  [codex returncode={result.returncode}]", file=sys.stderr)
            if result.stderr:
                print(f"  [stderr: {result.stderr[:200]}]", file=sys.stderr)
            return None
    except subprocess.TimeoutExpired:
        print("  [TIMEOUT]", file=sys.stderr)
        return None
    finally:
        try:
            os.unlink(out_file)
        except Exception:
            pass


def parse_json_array(text: str):
    """Robustly parse a JSON array from Codex output."""
    if not text:
        return None
    # Strip markdown fences
    fenced = re.search(r'```(?:json)?\s*\n(.*?)\n```', text, re.DOTALL)
    if fenced:
        text = fenced.group(1)
    # Try direct parse
    try:
        return json.loads(text)
    except json.JSONDecodeError:
        pass
    # Try fixing latex backslashes
    fixed = text.replace('\\', '\\\\')
    fixed = fixed.replace('\\\\"', '\\"').replace('\\\\n', '\\n').replace('\\\\t', '\\t').replace('\\\\r', '\\r')
    try:
        return json.loads(fixed)
    except json.JSONDecodeError:
        pass
    # Find bracket-delimited array
    m = re.search(r'\[\s*\{.*\}\s*\]', text, re.DOTALL)
    if m:
        try:
            return json.loads(m.group(0))
        except json.JSONDecodeError:
            try:
                fixed2 = m.group(0).replace('\\', '\\\\')
                fixed2 = fixed2.replace('\\\\"', '\\"').replace('\\\\n', '\\n').replace('\\\\t', '\\t')
                return json.loads(fixed2)
            except Exception:
                pass
    return None


def classify_note(note_data: dict) -> tuple[list, str | None]:
    """Classify all callouts in a single note. Returns (classified_callouts, raw_response)."""
    note_title = note_data['note_title']
    callouts = note_data['callouts']

    if not callouts:
        return [], None

    # Build the input list for the LLM
    callouts_for_prompt = []
    for c in callouts:
        # Truncate body if too long to keep prompt manageable
        body = c['body']
        if len(body) > 2000:
            body = body[:2000] + ' ...[truncated]'
        callouts_for_prompt.append({
            'id': c['id'],
            'type': c['type'],
            'title': c['title'],
            'body': body,
        })

    prompt = CLASSIFY_PROMPT_TEMPLATE.format(
        note_title=note_title,
        callouts_json=json.dumps(callouts_for_prompt, indent=2, ensure_ascii=False),
    )

    response = codex_call(prompt)
    if response is None:
        return [{'id': c['id'], 'error': 'codex_call_failed'} for c in callouts], None

    parsed = parse_json_array(response)
    if parsed is None:
        return [{'id': c['id'], 'error': 'json_parse_failed', 'raw_response_preview': response[:300]} for c in callouts], response

    return parsed, response


def main():
    callout_files = sorted(p for p in CALLOUTS_DIR.glob('*.json') if p.name != '_summary.json')
    print(f"Classifying {len(callout_files)} note files via Codex (gpt-5.4)...\n")

    total_classified = 0
    by_class = {}
    failed = []

    for i, cf in enumerate(callout_files, 1):
        note_data = json.loads(cf.read_text(encoding='utf-8'))
        title = note_data['note_title']
        n_callouts = len(note_data['callouts'])

        out_path = OUT_DIR / cf.name
        if out_path.exists():
            existing = json.loads(out_path.read_text(encoding='utf-8'))
            if existing.get('classified'):
                # Skip if already classified
                print(f"[{i}/{len(callout_files)}] {title} ({n_callouts} callouts) -- already classified, skipping")
                continue

        print(f"[{i}/{len(callout_files)}] {title} ({n_callouts} callouts) ...", flush=True)
        classified, raw = classify_note(note_data)

        # Merge classification into original callouts
        merged = []
        cls_by_id = {c.get('id'): c for c in classified if isinstance(c, dict)}
        for orig in note_data['callouts']:
            cls = cls_by_id.get(orig['id'], {'error': 'no_classification_returned'})
            merged.append({**orig, 'classification_result': cls})
            cls_kind = cls.get('classification', 'unknown') if isinstance(cls, dict) else 'unknown'
            by_class[cls_kind] = by_class.get(cls_kind, 0) + 1
            total_classified += 1

        out_data = {
            'note_title': title,
            'is_hub': note_data.get('is_hub', False),
            'in_subset_via': note_data.get('in_subset_via', []),
            'callouts': merged,
            'raw_codex_response': raw,
            'classified': True,
        }
        out_path.write_text(json.dumps(out_data, indent=2, ensure_ascii=False), encoding='utf-8')
        print(f"   -> saved to {out_path.name}")

    summary = {
        'total_callouts_classified': total_classified,
        'classification_distribution': by_class,
        'failed_notes': failed,
    }
    (OUT_DIR / '_summary.json').write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding='utf-8')
    print(f"\n=== CLASSIFICATION SUMMARY ===")
    print(f"Total callouts classified: {total_classified}")
    print(f"Distribution: {by_class}")


if __name__ == '__main__':
    main()
