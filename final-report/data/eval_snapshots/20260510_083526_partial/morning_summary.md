# Overnight Run — Morning Summary
**Generated**: 2026-05-10T08:35:45    **Manifest**: 2026-05-10T01:31:38

## Headline numbers
- Models: gpt-5.5, gpt-5.4-mini, claude-opus-4-7, deepseek-v4-pro, deepseek-v4-flash
- Problems: 30 (sampled from FAITHFUL audit pool of 148)
- Total cells: 191  passes: 42
- Codex-judge consultations: 1

## Prover leaderboard (Pass@K)

| model | condition | pass_rate | lean_proof | sympy_rescue | instruction_violation | compile_fail | model_timeout | n |
|---|---|---:|---:|---:|---:|---:|---:|---:|
| claude-opus-4-7 | lean_only | 0.25 | 5 | 0 | 2 | 0 | 13 | 20 |
| claude-opus-4-7 | with_sympy | 0.35 | 5 | 2 | 0 | 0 | 13 | 20 |
| deepseek-v4-flash | lean_only | 0.15 | 3 | 0 | 0 | 1 | 16 | 20 |
| deepseek-v4-flash | with_sympy | 0.20 | 4 | 0 | 1 | 0 | 15 | 20 |
| deepseek-v4-pro | lean_only | 0.13 | 2 | 0 | 0 | 0 | 13 | 15 |
| deepseek-v4-pro | with_sympy | 0.13 | 1 | 1 | 0 | 0 | 13 | 15 |
| gpt-5.4-mini | lean_only | 0.20 | 4 | 0 | 1 | 11 | 4 | 20 |
| gpt-5.4-mini | with_sympy | 0.10 | 2 | 0 | 1 | 12 | 5 | 20 |
| gpt-5.5 | lean_only | 0.29 | 6 | 0 | 3 | 12 | 0 | 21 |
| gpt-5.5 | with_sympy | 0.35 | 5 | 2 | 4 | 9 | 0 | 20 |

## Sympy-skill ablation (Δ pass rate)

| model | lean_only | with_sympy | Δ |
|---|---:|---:|---:|
| claude-opus-4-7 | 0.25 | 0.35 | +0.10 |
| deepseek-v4-flash | 0.15 | 0.20 | +0.05 |
| deepseek-v4-pro | 0.13 | 0.13 | +0.00 |
| gpt-5.4-mini | 0.20 | 0.10 | -0.10 |
| gpt-5.5 | 0.29 | 0.35 | +0.06 |

## Hub-recall task

| model | precision | recall | F1 | n |
|---|---:|---:|---:|---:|

## Anomalies
- (none)

## What to look at first
1. `figures/leaderboard_pass_rate.png` — model × condition pass rates.
2. `figures/sympy_ablation.png` — Δ from sympy-skill.
3. `figures/hub_recall_pr.png` — categorical-gap quantification.
4. `decision_log.jsonl` — every codex-judge consultation.
5. `aggregate.json` — full numbers.
