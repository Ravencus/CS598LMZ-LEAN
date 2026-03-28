# Reasoning Trace: Complex Subset Sum

**Problem:** Given z₁, ..., zₙ with ∑|zᵢ| = 1, prove ∃ subset S with |∑_{k∈S} zₖ| ≥ 1/6.

---

## Step 1: Strip the surface

The problem says "complex numbers" but that's just encoding. The real structure is:
- n vectors in ℝ² (2D vectors)
- Constraint on sum of lengths (∑‖vₖ‖ = 1)
- Goal: find a subset whose vector sum has large magnitude

Complex number notation is convenient but not essential. This is a geometric problem about 2D vectors and directional alignment.

## Step 2: Analyze the objective

What are we actually bounding? The norm of a subset sum: ‖∑_S zₖ‖.

Key questions:
- What makes this hard? The vectors point in different directions and cancel.
- What makes a subset good? Vectors that "mostly agree" in direction.
- What's the enemy? Angular spread — vectors pointing opposite ways cancel.

## Step 3: Simplify — start with small cases

**n = 1:** Trivially |z₁| = 1, take S = {1}.

**n = 2:** z₁ and z₂ with |z₁| + |z₂| = 1. Take whichever has larger modulus. Get ≥ 1/2.

**n = 2, worst case:** z₁ = 1/2, z₂ = -1/2. Either singleton gives 1/2. The pair gives 0. So we must choose carefully — taking everything can be worse than a subset.

This tells us: the problem is about **selection**, not just summation.

## Step 4: Probe the bound — why 1/6?

The problem states ≥ 1/6. A mathematician reads the constant and asks:
- Is 1/6 tight? Can we always do better?
- What determines 1/6? Can we decompose it?

1/6 = (1/3)(1/2) suggests two sources of loss multiplied together.

## Step 5: The sector approach (gives exactly 1/6)

**Idea:** Partition the plane into 3 sectors of angle 2π/3. By pigeonhole, one sector contains vectors whose moduli sum to ≥ 1/3. Within that sector, all vectors are within angle π/3 of the bisector, so projection onto the bisector loses at most cos(π/3) = 1/2.

**Bound:** (1/3)(1/2) = 1/6.

**Parameterize:** With k sectors, the bound is cos(π/k)/k.
- k=2: cos(π/2)/2 = 0 (useless — a full semicircle has projection 0 at the boundary)
- k=3: cos(π/3)/3 = 1/6
- k=4: cos(π/4)/4 ≈ 0.177
- k=5: cos(π/5)/5 ≈ 0.162
- k→∞: approaches 0

The sector approach peaks around k=4, not k=3. So 1/6 is not even the best this method gives.

## Step 6: The quadrant approach (gives 1/4)

**Idea:** Don't use angles at all. Decompose into real and imaginary parts.

Define four quantities:
- a = ∑ Re(zₖ) over {k : Re(zₖ) ≥ 0}
- b = ∑ |Re(zₖ)| over {k : Re(zₖ) < 0}
- c = ∑ Im(zₖ) over {k : Im(zₖ) ≥ 0}
- d = ∑ |Im(zₖ)| over {k : Im(zₖ) < 0}

Key inequality: a + b + c + d = ∑(|Re zₖ| + |Im zₖ|) ≥ ∑‖zₖ‖ = 1.

So max(a,b,c,d) ≥ 1/4. If a ≥ 1/4, take S = {k : Re(zₖ) ≥ 0}. Then ‖∑_S zₖ‖ ≥ Re(∑_S zₖ) = a ≥ 1/4.

**This is simpler than the sector approach and gives a stronger bound.**

## Step 7: Can we do even better? The averaging approach (gives 1/π)

**Idea:** Instead of a fixed partition, average over ALL directions.

For each angle α ∈ [0, 2π), take S_α = {k : projection of zₖ onto direction α is ≥ 0}. Define F(α) = sum of positive projections.

Compute the average:
- For each k, ∫₀²π max(‖zₖ‖ cos(θₖ - α), 0) dα = 2‖zₖ‖
- Summing: ∫₀²π F(α) dα = 2∑‖zₖ‖ = 2
- Average: (1/2π) · 2 = **1/π**

Since the average is 1/π, some α₀ achieves F(α₀) ≥ 1/π. And F(α₀) ≤ ‖∑_{S_{α₀}} zₖ‖.

## Step 8: Is 1/π optimal?

**Candidate extremal configuration:** n vectors uniformly spaced around the unit circle, each with modulus 1/n. As n → ∞, the best subset is a semicircle. The sum of a semicircle of uniformly distributed unit vectors approaches:

∫_{-π/2}^{π/2} e^{iθ} dθ/(2π) = 1/π

So the uniform distribution achieves exactly 1/π and no better. Since the averaging argument also gives 1/π as an upper bound on the guaranteed minimum, **1/π is the optimal constant**.

## Step 9: The bound landscape

| Method | Bound | Key idea |
|--------|-------|----------|
| 3 sectors + pigeonhole | 1/6 ≈ 0.167 | Partition angles, pigeonhole |
| k sectors (optimized) | cos(π/4)/4 ≈ 0.177 | Same, k=4 |
| Quadrant decomposition | 1/4 = 0.250 | Re/Im sign split |
| Averaging over directions | **1/π ≈ 0.318** | Probabilistic method |
| Uniform distribution lower bound | 1/π ≈ 0.318 | Extremal example |

The progression from 1/6 to 1/π is not just "better bounds" — each step uses a fundamentally different technique: discrete pigeonhole → coordinate decomposition → continuous averaging.

## Step 10: Connections to other problems

The "pigeonhole on directions" trick appears in:
- **Unit vectors summing to zero:** Split by halfplane, get subset summing to norm ≥ 1.
- **Exponential sums in number theory:** Bounding ∑e^{2πimθₖ} by partitioning the circle.
- **Steinitz lemma (2D):** Reordering vectors so all partial sums are bounded — uses directional arguments in the analysis.
- **Points on a circle:** Finding a diameter that maximizes total signed distance.

Common structure: collection of 2D vectors → angular spread is the enemy → partition/average over directions → concentration vs. alignment tradeoff.

## Exploration Strategies (human problem-solving patterns)

The following strategies were used in this exploration. They are **general-purpose** — not specific to this problem — and represent how humans build understanding of a new problem.

### Strategy 1: Start from simple cases

Before attacking the general problem, reduce to the simplest non-trivial instance. Here: n=1 (trivial), n=2 (reveals that selection matters — taking everything can cancel). The simple case exposes the core difficulty (directional cancellation) without the complexity of the general case.

**Why this works:** Many properties that hold for the simple case persist in the general case. Understanding n=2 deeply gives intuition that carries forward. Also, simple cases can reveal whether the problem is about selection, ordering, approximation, etc. — clarifying the nature of the task.

**When to apply:** Always. Before planning a proof strategy, ask: "What happens with 2 elements? With 3?"

### Strategy 2: Probe the bound, don't just prove it

The problem asks for ≥ 1/6. A naive approach is to prove exactly that. A deeper approach asks:
- Is 1/6 tight? What if I try to prove ≥ 1/4?
- What's the optimal bound? What extremal examples exist?
- What parameter controls the bound? (Here: number of sectors k, giving cos(π/k)/k)

This transforms a single proof task into a **landscape exploration**: the problem is not "prove 1/6" but "understand the space of bounds and methods."

**Why this works:** A loose bound (1/6) often has a simpler proof than a tight one (1/π). By exploring the landscape, you may find an easier path to a stronger result. You also gain understanding of *why* the bound is what it is — which is transferable knowledge.

**When to apply:** Whenever the problem contains a specific constant. Ask: "Is this the right constant? What happens if I change it?"

### Strategy 3: Construct counterexamples to find ceilings

Don't just prove lower bounds — construct configurations that are hard for any method. Here: n vectors uniformly on the unit circle, each with modulus 1/n. This is the "worst case" for subset selection, and it gives exactly 1/π.

Counterexamples shape the landscape from above: they tell you what you *cannot* prove, which is as important as what you can.

**Why this works:** Without a ceiling, you don't know if your bound is good. With both a proof (floor) and a counterexample (ceiling), you understand the problem completely when they match.

**When to apply:** After proving any bound, ask: "Can I construct an example that achieves exactly this bound? If not, my bound is loose."

### Strategy 4: Decompose the problem into knowledge components

Instead of making a linear plan to solve the problem, decompose it into independent exploration directions:
- Direction A: prove the stated bound (1/6)
- Direction B: find the optimal bound
- Direction C: construct extremal examples
- Direction D: connect to known techniques (pigeonhole on directions)
- Direction E: formalize in Lean

Each direction yields knowledge independently. Direction B (finding 1/π) is harder than Direction A (proving 1/6) but produces deeper understanding. A human chooses which directions to explore based on time and interest.

**Why this works:** A single problem contains multiple layers of insight. A linear approach ("just prove it") captures one layer. Decomposition captures many.

**When to apply:** When facing a new problem, list not just "how to solve it" but "what can I learn from it."

### What LLMs miss

An LLM given this problem will:
1. Recall a proof from training data (pattern match)
2. Generate that proof (or a minor variant)
3. Done

It skips: simple case analysis, bound probing, counterexample construction, landscape mapping, knowledge decomposition. These are the activities that build transferable understanding. They are absent from (problem, proof) training pairs because only the final proof is recorded.

This is the core claim: **the exploration process, not the proof, is where human mathematical knowledge is built.** Capturing and distilling this process is the goal of the lesson agent.

## Meta-observations

1. **The constant reverse-engineers the proof.** Seeing 1/6 = (1/3)(1/2) suggests the proof structure before you find it.
2. **Simpler methods can give stronger bounds.** The quadrant approach (1/4) is both simpler and stronger than the sector approach (1/6). Elegance and strength don't always correlate.
3. **The optimal proof is the hardest to formalize.** The averaging argument (1/π) is the most elegant on paper but requires integration machinery in Lean. The quadrant proof (1/4) is clunky but fully formalizable.
4. **Exploring the bound landscape IS the knowledge.** A human who works through 1/6 → 1/4 → 1/π understands the problem deeply. A human who only sees the 1/π proof knows the answer but not the landscape.
5. **Training data contains (problem, proof) pairs but not this exploration.** The progression through weaker bounds, the parameter sweep over k sectors, the counterexample construction — these are absent from datasets. An LLM can reproduce the 1/π proof from memory but cannot reconstruct the exploration path.
6. **LLM summarization of lessons is shallow.** When asked to summarize the quadrant proof, an LLM might produce: "When bounding the norm of a vector sum, decompose by coordinate signs." This is misleading — it works in 2D but not in higher dimensions, and "coordinate signs" is a surface feature of one specific proof, not the underlying principle. The actual insight is about **projection onto a direction** and the tradeoff between concentration and alignment. Humans understand this distinction because they explored the landscape (sectors → quadrants → continuous averaging); an LLM that only saw the quadrant proof does not.
