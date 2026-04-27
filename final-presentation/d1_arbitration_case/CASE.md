# D1 Demo Case: GPT5.4 Wrong Inequality (Sin Difference Quotient)

## Provenance

This is a **real, documented** GPT5.4 error captured by a human mathematician (Ravencus) during normal use, not a synthetic test case.

- **Source note:** `/workspace/math-notes/笔记共享vault/script/GPT5.4在数学学习者使用需求下的测试.md` (section 1.3 "寻找边界案例的测试")
- **Original screenshots:** `/workspace/math-notes/笔记共享vault/图片_math/gpt 5.4 test 12.png`, `gpt 5.4 test 13.png`
- **Reference:** `通过图像猜测或校验答案#2.2 多元函数不等式` — same error pattern previously seen in GPT-o3, persists in GPT5.4
- **Visualization of the error:** `/workspace/math-notes/笔记共享vault/图片/MVT不等式证明局限性_AI给出的错误例子.png`, `O3给出的一个错误的不等式对应的函数的取值.png`

## The Error

User asked GPT5.4 (thinking mode) for trigonometric counterexamples in the context of MVT-style inequalities. Among its responses, GPT5.4 confidently asserted:

> For $0 < a < b < \pi$:
> $$\frac{\sin b - \sin a}{b - a} < \cos\frac{a+b}{2}$$

**This claim is FALSE.** The strict inequality fails whenever $a + b > \pi$ (where the cosine sign flips). After the user pointed this out, GPT5.4 admitted: *"You are right. The trigonometric example I gave was wrong on the full interval $(0, \pi)$. The failure is exactly a sign issue: $\cos((a+b)/2)$ changes sign when $a+b$ crosses $\pi$."*

## The Correct Statement

The valid inequality (proved via sum-to-product identity):
$$\frac{\sin b - \sin a}{b - a} = \cos\frac{a+b}{2} \cdot \frac{\sin\frac{b-a}{2}}{\frac{b-a}{2}}$$

Since $\frac{\sin t}{t} \le 1$ for $t > 0$, when $\cos\frac{a+b}{2} \ge 0$ (i.e., $a+b \le \pi$):
$$\frac{\sin b - \sin a}{b - a} \le \cos\frac{a+b}{2}$$

When $\cos\frac{a+b}{2} < 0$ (i.e., $a+b > \pi$), multiplying by $\frac{\sin t}{t} \in (0, 1]$ moves the negative number *closer to zero*, so the inequality **reverses**.

GPT5.4 missed the sign-flip case and stated the inequality with strict $<$ uniformly across $(0, \pi)$.

## Numerical Verification (sympy/numpy)

Counterexamples found by simple point-evaluation:

| $a$ | $b$ | $a+b$ | LHS = $\frac{\sin b - \sin a}{b-a}$ | RHS = $\cos\frac{a+b}{2}$ | LHS < RHS? |
|-----|-----|-------|--------------------------------------|----------------------------|------------|
| 0.1 | 0.5 | 0.6 | +0.948980 | +0.955336 | **True** (claim holds) |
| 1.0 | 2.0 | 3.0 | +0.067826 | +0.070737 | **True** (claim holds) |
| 1.5 | 2.5 | 4.0 | −0.399023 | −0.416147 | **False** ✗ COUNTEREXAMPLE |
| 1.5 | 3.0 | 4.5 | −0.570917 | −0.628174 | **False** ✗ COUNTEREXAMPLE |
| 2.0 | 3.0 | 5.0 | −0.768177 | −0.801144 | **False** ✗ COUNTEREXAMPLE |
| π/2 | 3π/4 | 5π/4 | −0.372923 | −0.382683 | **False** ✗ COUNTEREXAMPLE |
| π/4 | 3π/4 | π | 0 | 0 | **False** (only equal, not strict) |

A simple grid evaluation across $(0, \pi)^2$ finds the counterexample region in milliseconds.

## Why This Case is the Right Demo

1. **Real failure, not synthetic.** Documented in human's notes from actual use, persists across model versions (o3 → 5.4).

2. **Computational claim, not algebraic scaffolding.** The inequality has a definite truth value on a stated domain. This is exactly what our arbitrator is designed to verify (unlike partial-fraction constraint equations, which were the false-positive trap in our v2 eval).

3. **Outcome flips with arbitration.**
   - Without arbitrator: user accepts confident-sounding wrong claim → propagates a false inequality into their work
   - With arbitrator: claim flagged with concrete counterexample → user knows to revise

4. **Generalizes to mathematical research practice.** Generating plausible-looking but false inequalities is a well-known LLM failure mode in proof construction. Our user (Ravencus) explicitly says: *"即便有一天它的数学能力强大到可以媲美Grothendieck，它还是可能会像人类一样犯错。因此，确定性的计算机程序依旧是检验错误的必不可少的工具，这一点AI并不能将之取代."* ("Even if AI math ability one day rivals Grothendieck, it can still err like humans. Deterministic computer programs remain indispensable for error checking — AI cannot replace them.")

5. **Maps cleanly to the design doc's framing.**
   - Three-layer problem (Q1): inequality verification is computation, not strategy or mechanization
   - Reasoning Arbitration: the arbitrator routes the claim to sympy's numerical/symbolic checker
   - Class relevance: this is fault localization (find which claim is wrong) + patch generation (provide counterexample)

## Demo Plan

**Goal:** Reproduce the failure with our pipeline and show the arbitrator catching it.

### Step 1: Reproduce the failure with Codex
Send Codex (GPT5.4) a prompt similar to the original — about borderline MVT-style trigonometric inequalities. Capture full output to disk.

- Prompt to use (translated from Chinese): "Find a counterexample of the form involving $\sin$ or $\cos$ functions, an inequality on $(a,b) \subset \mathbb{R}$ that looks like it could be proved via the mean value theorem but actually fails on part of its stated domain."
- Save: `final-presentation/d1_arbitration_case/codex_output.txt`

If GPT5.4 doesn't make the same error this time (mood/temperature variance), we have the original screenshots as the evidence.

### Step 2: Extract the inequality claim via LLM
Pass the output through `reasoning_arbitrator.extract_claims_llm()` with the 300s timeout. The extractor should produce something like:

```json
{
  "raw_text": "(sin b - sin a)/(b - a) < cos((a+b)/2) for 0 < a < b < pi",
  "claim_type": "inequality",
  "sympy_kwargs": {
    "lhs_str": "(sin(b) - sin(a))/(b - a)",
    "op": "<",
    "rhs_str": "cos((a+b)/2)"
  }
}
```

Save: `final-presentation/d1_arbitration_case/extracted_claim.json`

### Step 3: Extend the verifier to handle parameterized claims
Our current `verify_inequality` evaluates LHS and RHS as numbers. For a parameterized inequality on a domain, we need:

- Domain-aware checking: pick sample points $(a, b)$ in the stated domain $0 < a < b < \pi$
- Evaluate LHS - RHS at each point
- If any point violates: report as counterexample
- If all points satisfy: report as "no counterexample found in $N$ samples" (not a proof of validity)

Save the verification result: `final-presentation/d1_arbitration_case/verification.json`

### Step 4: Generate the demo artifact
A side-by-side document showing:
1. The original GPT5.4 (Codex) output with the wrong claim highlighted
2. The arbitrator's extraction
3. The sympy verification with concrete counterexamples
4. The corrected output with `[ARBITRATOR FLAG: counterexample at a=π/2, b=3π/4]` annotation

Save: `final-presentation/d1_arbitration_case/demo_writeup.md`

### Step 5: Visualization (optional)
Plot LHS - RHS over $(0, \pi)^2$ to visualize the failure region (similar to the human's `O3给出的一个错误的不等式对应的函数的取值.png`).

Save: `final-presentation/d1_arbitration_case/failure_region.png`

## What This Demo Does NOT Claim

- It does not claim that GPT5.4 always fails on inequalities. It usually doesn't.
- It does not claim our arbitrator handles arbitrary parameterized inequalities. It needs Step 3 (domain sampling) — currently handles only specific-value claims.
- It does not replace the broader v2 eval; it complements it with one clean qualitative case.

## Status

- [x] Case identified and documented
- [x] Wrong inequality numerically verified (counterexamples found)
- [ ] Codex reproduction of the failure
- [ ] Pipeline run (extraction → verification → annotation)
- [ ] Demo artifact prepared
- [ ] Visualization (optional)
