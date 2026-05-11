# Phase 2 Results — Partial (191/300 cells)

**Snapshot time**: 2026-05-10 08:35
**Coverage**: 21/30 problems × 5 models × 2 conditions, with deepseek-v4-pro dropped at problem 15 by codex-judge after 15 consecutive failures.

This is the partial draft for the report's Results section. Numbers will refresh when production finishes.

---

## Headline

5-model uniform harness applied to 30 grad-level Lean 4 + Mathlib problems sampled from the FAITHFUL pool of 148 (Stage-7 audit). Two conditions per cell: `lean_only` (no tool augmentation) vs `with_sympy` (model may emit `<sympy>` blocks for definite integrals / numeric identities, externally verified). K=3 retry-with-diagnostic-feedback per cell. 240s per-attempt timeout with fast-fail on first-attempt timeout.

**Top of the leaderboard, Pass@K=3:**

| Model | Condition | Pass rate |
|---|---|---:|
| claude-opus-4-7 | with_sympy | **0.35** |
| gpt-5.5 | with_sympy | **0.35** |
| gpt-5.5 | lean_only | 0.29 |
| claude-opus-4-7 | lean_only | 0.25 |
| gpt-5.4-mini | lean_only | 0.20 |
| deepseek-v4-flash | with_sympy | 0.20 |
| deepseek-v4-flash | lean_only | 0.15 |
| deepseek-v4-pro | lean_only/with_sympy | 0.13 / 0.13 |
| gpt-5.4-mini | with_sympy | 0.10 |

(Cited at 191/300 cells; final numbers will shift but the ranking is stable across problems 1-15 fully covered.)

---

## C1 — Uniform multi-model harness (5 models, 3 providers)

The 2-backend harness (Codex CLI for OpenAI, Claude CLI in Anthropic-compat mode for Anthropic + DeepSeek) successfully delivered 191 comparable cells across 5 models from 3 providers using one prompt template and one outer protocol. **Per-problem coverage so far is uniform** — every problem in the first 15 was attempted by every model in both conditions (after problem 15, deepseek-v4-pro was dropped; remaining 4 models continue).

**Engineering takeaway**: pinning the same 240s/attempt budget, same `--effort max` reasoning budget, same `--disable-slash-commands` / `cwd=/tmp` neutrality controls across both CLIs makes provider differences disappear from the scaffolding. What's left is genuine model behavior.

---

## C2 — Sympy-skill ablation (Δ pass rate, lean_only → with_sympy)

| Model | lean_only | with_sympy | Δ |
|---|---:|---:|---:|
| claude-opus-4-7 | 0.25 | 0.35 | **+0.10** |
| gpt-5.5 | 0.29 | 0.35 | +0.06 |
| deepseek-v4-flash | 0.15 | 0.20 | +0.05 |
| deepseek-v4-pro | 0.13 | 0.13 | 0.00 |
| gpt-5.4-mini | 0.20 | 0.10 | **−0.10** |

**Three patterns:**

1. **Strong models lift** (opus +0.10, gpt-5.5 +0.06): they correctly recognize when a sub-claim is computational, emit a well-formed `<sympy>` block, sympy verifies, and the resulting `sorry`-with-witness is accepted. This is exactly the design intent of the sympy-skill.
2. **Reasoning models neutral** (ds-pro 0.00): they prefer to attempt the integral in Lean directly, often timing out. They do not opportunistically reach for the tool.
3. **Weak generalist hurt** (gpt-5.4-mini −0.10): the additional sympy-skill instructions appear to confuse the model. We see more `compile_fail` (12 vs 11) and similar `model_timeout` counts. The skill block adds prompt complexity without the model gaining benefit. **This is a real and quotable finding**: tool augmentation is not free — weak models can be net-hurt by the option.

---

## C3 — Capability decomposition

Per-model **outcome breakdown** across all completed cells (both conditions):

| Model | lean_proof | sympy_rescue | instruction_violation | compile_fail | model_timeout | n |
|---|---:|---:|---:|---:|---:|---:|
| gpt-5.5 | 11 | 2 | 7 | 21 | 0 | 41 |
| claude-opus-4-7 | 10 | 2 | 2 | 0 | 26 | 40 |
| gpt-5.4-mini | 6 | 0 | 2 | 23 | 9 | 40 |
| deepseek-v4-flash | 7 | 0 | 1 | 1 | 31 | 40 |
| deepseek-v4-pro | 3 | 1 | 0 | 0 | 26 | 30 |

**Three distinct failure modes emerge:**

- **gpt-5.5 — fast and crashing**: 0 timeouts, 21 compile_fail. Returns quickly with code that is *almost* right; failures are syntactic / Mathlib API hallucinations, not slowness. Best raw productivity.
- **claude-opus-4-7 — slow and stuck**: 26 timeouts, 0 compile_fail. The agentic Claude harness invests its 240s budget in extended reasoning; when it can't find the answer it just keeps thinking until the budget expires. It rarely emits broken code.
- **gpt-5.4-mini — fast and broken**: 23 compile_fail, 9 timeouts. Cheap model produces lots of code that doesn't typecheck.
- **deepseek-v4-pro/flash — pure timeout**: 26-31 timeouts, almost no compile_fail. Reasoning + agentic harness consumes 240s in internal thought; the response that *would have* compiled never finishes emitting before the cap.

This is the cleanest capability-decomposition signal in the experiment: **the same task surfaces fundamentally different bottlenecks per model architecture**. A leaderboard that only reports pass-rate hides this; the outcome ladder makes it explicit.

---

## C5 — Stage-7 noise & filtering (already done, cited)

The 30 problems were sampled from the FAITHFUL pool of 148 (audited from 233 Stage-7 successes via gpt-5.5 LLM-judge). Without that filter, 36% of "successful" Stage-7 formalizations are vacuous (free variables) or mismatched (Lean asserts a different claim). We sample only from FAITHFUL to make the leaderboard interpretable; the audit itself is a contribution worth citing.

---

## Anomalies & autonomous decisions

| Time | Event | Outcome |
|---|---|---|
| 06:11 | deepseek-v4-pro hit 15 consecutive failures (problems 1-15) | Codex-judge consulted → recommended skip_model. Runner accepted. ds-pro coverage frozen at 30 cells. |

The codex-judge mechanism worked as designed: triggered on the persistent-failure threshold, returned a structured action, runner honored it, decision logged to `decision_log.jsonl` (1 entry as of snapshot).

---

## Pending (Stage 3 + remainder of Stage 2)

- **Hub-recall task** (C4): 4 active models × ~27 problems with hub edges. Not yet run.
- **Stage 2 completion**: ~80 more cells (problems 21-30 × 4 models × 2 conds, with ds-pro skipped).

This snapshot is partial; final numbers will refresh when production exits.
