"""
Stage 3a: Deterministic callout parsing.

Parse each selected note for Obsidian callout blocks (`> [!type] title\n> body...`).
A callout block:
  - Starts with a line matching `^> \[!(\w+)\]\s*(.*)$`
  - Continues with subsequent lines starting with `>` (or `> `)
  - Ends at the first non-`>` line

For each callout, capture:
  - type (note / question / tip / example / abstract / warning / etc.)
  - title (text after [!type])
  - body (the markdown content, with `>` prefixes stripped)
  - position (character offset in source note)
"""

import json
import re
import unicodedata
from pathlib import Path

VAULT_DIR = Path("/workspace/math-notes/笔记共享vault/math")
SUBSET = Path("/workspace/final-presentation/d2_curation_v2/data/subset.json")
OUT_DIR = Path("/workspace/final-presentation/d2_curation_v2/data/callouts")
OUT_DIR.mkdir(parents=True, exist_ok=True)

CALLOUT_HEADER_RE = re.compile(r'^>\s*\[!(\w+)\](?:\s*(.*))?$')
QUOTE_LINE_RE = re.compile(r'^>(?:\s*(.*))?$')


def safe_filename(title: str) -> str:
    """Make a filesystem-safe filename from a possibly-Chinese title."""
    # NFKD normalize to strip accents, drop control chars, collapse whitespace
    s = unicodedata.normalize('NFKC', title)
    # replace path separators
    s = s.replace('/', '_').replace('\\', '_')
    return s


def parse_callouts(content: str, note_title: str) -> list[dict]:
    """Parse all callout blocks in a note."""
    lines = content.split('\n')
    callouts = []
    i = 0
    char_pos = 0

    # Build cumulative char offset map
    line_offsets = []
    pos = 0
    for line in lines:
        line_offsets.append(pos)
        pos += len(line) + 1  # +1 for newline

    while i < len(lines):
        m = CALLOUT_HEADER_RE.match(lines[i])
        if not m:
            i += 1
            continue
        cl_type = m.group(1)
        cl_title = (m.group(2) or '').strip()
        body_lines = []
        start_line = i
        position = line_offsets[i]
        # collect body lines
        j = i + 1
        while j < len(lines):
            qm = QUOTE_LINE_RE.match(lines[j])
            if not qm:
                break
            body_text = qm.group(1) or ''
            body_lines.append(body_text)
            j += 1
        body = '\n'.join(body_lines).rstrip()

        callout_id = f"{safe_filename(note_title)}#{len(callouts)+1}"
        callouts.append({
            'id': callout_id,
            'type': cl_type,
            'title': cl_title,
            'body': body,
            'position_char': position,
            'position_line': start_line,
        })
        i = j

    return callouts


def main():
    subset = json.loads(SUBSET.read_text(encoding='utf-8'))
    notes = subset['selected_notes']
    print(f"Parsing callouts for {len(notes)} selected notes...\n")

    total_callouts = 0
    by_type = {}
    per_note_summary = []

    for note in notes:
        title = note['title']
        path = VAULT_DIR / f"{title}.md"
        if not path.exists():
            print(f"  MISSING: {title}")
            continue
        content = path.read_text(encoding='utf-8')
        callouts = parse_callouts(content, title)
        total_callouts += len(callouts)
        for c in callouts:
            by_type[c['type']] = by_type.get(c['type'], 0) + 1

        # Save per-note callout file
        out_data = {
            'note_title': title,
            'is_hub': note['is_hub'],
            'in_subset_via': note['in_subset_via'],
            'callouts': callouts,
        }
        safe_name = safe_filename(title)
        out_path = OUT_DIR / f"{safe_name}.json"
        out_path.write_text(json.dumps(out_data, indent=2, ensure_ascii=False), encoding='utf-8')

        per_note_summary.append({
            'title': title,
            'callout_count': len(callouts),
        })
        print(f"  {len(callouts):>3} callouts in: {title}")

    # Save summary
    summary = {
        'total_callouts': total_callouts,
        'callouts_by_type': dict(sorted(by_type.items(), key=lambda x: -x[1])),
        'per_note': per_note_summary,
    }
    summary_path = OUT_DIR / '_summary.json'
    summary_path.write_text(json.dumps(summary, indent=2, ensure_ascii=False), encoding='utf-8')

    print(f"\n=== CALLOUT PARSING SUMMARY ===")
    print(f"Total callouts: {total_callouts}")
    print(f"By type: {summary['callouts_by_type']}")
    print(f"Per-note files saved in: {OUT_DIR}")


if __name__ == '__main__':
    main()
