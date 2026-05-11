# Speaker Script — CS598LMZ Final Presentation

**Total target: ~880 words for 7 min (with 2 min Q&A buffer) at 125 wpm.**
**Stretch target: ~1100 words for full 9 min.**

## Word budget per slide

| # | Slide | Words | Approx sec @ 125 wpm |
|---|---|---|---|
| 1 | Title | ~25 | 12 |
| 2 | Age of Human / Age of AI | ~40 | 20 |
| 3 | Recap: problem & solution | ~95 | 45 |
| 4 | Recap: eval methodology + midterm | ~95 | 45 |
| 5 | Result 1: Asymmetric utility | ~115 | 55 |
| 6 | Result 2: Can of worms | ~125 | 60 |
| 7 | Result 3: Sorry-with-witness | ~125 | 60 |
| 8 | Result 4: Ablation | ~135 | 65 |
| 9 | Future work | ~100 | 48 |
| | **Total** | **~880** | **~7 min** |

---

## Slide 1 — Title

**On screen:**
- Title: *Structured AI Theorem Proving with Human-Learnable Knowledge Extraction*
- Author: Zihan Zheng

**Script (~25 words):**

> Hi, I'm Zihan. My project is on **structured AI theorem proving**, with a focus on extracting knowledge from proof traces in a way that humans — not just compilers — can actually learn from.

---

## Slide 2 — Age of Human / Age of AI (recap)

**Script (~46 words):**

> Quick recap from the midterm. The gap we care about isn't just *can AI prove theorems* — that part is moving fast. The harder question is: when AI hands you a proof, can a *human* actually learn from it — gain intuition, derive new methodology, and apply it elsewhere? That's what motivates the rest of the talk.

**Tighter alternative (~35 words):**

> Quick recap. The gap isn't just *making AI prove theorems* — that's moving fast. It's letting *humans* learn from the proofs: intuition, methodology, transfer. That's what motivates everything we'll show today.

**Pacing tip:** advance early into slide 3 — both 2 and 3 are recap, so keep momentum.

---

## Slide 3 — Recap: Problem Statement & Solution

**Script (~125 words, ~60 sec):**

> There are two specific gaps that motivate the work. First — **mechanization isn't reasoning**. When AI tries to prove a theorem, peripheral errors — wrong API names, syntax glitches — get conflated with intrinsic mathematical difficulty. Our first solution is to decouple the two: *thinking*, by which I mean subgoal decomposition and high-level strategy, from *labor*, by which I mean calculation and formalization.
>
> Second gap — **verified isn't understanding**. Current systems optimize for "does it compile?" and just discard everything else: the trace, the dead ends, the intuition. We respond with two pieces. A **digest agent** that extracts strategies and relational structure from proof traces. And a **ground-truth relational dataset** of grad-level math problems, so we can actually evaluate what the digest recovers.
>
> The overarching goal: AI-assisted proofs that enhance human understanding, not just accumulate verified truths.

**Pacing tips:**
- Don't read the slide bullets verbatim — state the two gaps and three solutions in your own words; the audience reads the slide for the details.
- Brief pause (1 sec) after each "X isn't Y" framing — those are the key sticky phrases.
- Emphasize the bold pairings: *mechanization* / *reasoning*, *verified* / *understanding*. These are what the audience should remember.
- Total slide time including pauses ≈ 60 sec.

**Tighter alternative (~95 words)** if you're running long:

> Two gaps from the midterm. First, **mechanization isn't reasoning** — peripheral errors get conflated with intrinsic difficulty. Our first solution: decouple *thinking* (subgoal decomposition) from *labor* (calculation, formalization). Second, **verified isn't understanding** — current systems optimize "does it compile?" and discard everything else. Two responses: a **digest agent** that extracts strategies and relational structure from proof traces, and a **ground-truth relational dataset** of grad-level math problems to evaluate it against. The overall goal: proofs that enhance human understanding, not just accumulate verified truths.

---

## Slide 4 — Recap: Evaluation Methodology & Midterm Results

**Script (~125 words, ~60 sec):**

> Three evaluation axes, drawn from a single data source. The raw data is a **455-note Obsidian vault** — a graduate-level math knowledge base with **1,596 explicit relational links**. Few general strategies, many specific problems pointing back to them.
>
> We evaluate three things. First, **data curation and relation extraction** — turning the vault into a dataset of formal problem statements with edges. Second, **prover effectiveness** — does our structured Plan-Implement-Replan agent compile more Lean proofs than a free-agent baseline, measured by Pass@k? Third, **digest quality** — given a proof trace, does the digest recover the ground-truth edges in the relational graph, measured by precision and recall?
>
> At the midterm we had preliminary evidence on each axis at small scale. The next four slides are what we did *after* the midterm to push each of these further.

**Pacing tips:**
- The "455 notes / 1,596 edges" numbers are sticky — let them land with a brief pause.
- Number the three axes verbally ("First… Second… Third…") so the audience can follow even without reading.
- The closing line ("the next four slides are what we did after midterm…") is the **transition**: it cues the audience that the recap section is over and results start now. Land it cleanly.
- Total slide time ≈ 60 sec.

**Tighter alternative (~95 words):**

> Three evaluation axes from one data source: the 455-note Obsidian vault — graduate-level math with 1,596 relational links. Few general strategies, many specific problems pointing back. We evaluate **data curation** (turning the vault into formal problem statements with edges), **prover effectiveness** (does our Plan-Implement-Replan agent beat free agents on Pass@k?), and **digest quality** (does the digest recover ground-truth edges, measured by precision and recall?). At the midterm we had preliminary evidence on each axis at small scale. The next four slides are what we did after midterm to push each further.

---

## Slide 5 — Result 1: Dataset Asymmetric Utility

**Script (~115 words, ~55 sec):**

> Our first result: the dataset has asymmetric utility — two directions of use, one solved, one open.
>
> **Forward direction works.** A graph edge encodes ground truth that two problems share a strategy. Enables hub-recall benchmarks, transfer experiments, conditioned training. Scaled up since midterm: **105 of 455 notes curated**, **461 nodes — 439 problems plus 22 hubs**, **7,415 edges**, and **81% of statements compile in Lean**.
>
> **Reverse direction is open.** Given two digest outputs in natural language, are they "the same intuition"? Different wording, same idea — vs — same wording, too problem-specific? Semantic equivalence in NL math reasoning isn't solved. That blocks direct evaluation of the digest agent.
>
> So: contribution *and* limitation. Dataset is ready for forward use; reverse-direction evaluation is the open problem.

**Pacing tips:**
- The numbers (105/455, 439 problems, 7,415 edges, **81%**) are the headline — let each land with a brief pause. Audience anchors on these.
- "Forward works / reverse open" is the two-beat structure of the slide. Make the transition between the two clear (e.g., turn slightly to the right side of the slide).
- The closing line ("contribution AND limitation") is the slide's headline takeaway — slow down on it.
- Total slide time ≈ 55 sec.

**Tighter alternative (~95 words):**

> Our dataset has asymmetric utility — two directions, one solved, one open. **Forward works:** graph edge = ground truth that two problems share a strategy. Numbers, scaled up since midterm: 105 of 455 notes curated, 439 problem nodes plus 22 hubs, 7,415 edges, **81% Lean compile rate**. **Reverse is open:** given two NL digest outputs, are they "the same intuition"? Semantic equivalence in math reasoning isn't solved — and that blocks direct evaluation of the digest. So the dataset is contribution and limitation in one: ready for forward use, reverse evaluation is the open problem.

---

## Slide 6 — Result 2: Opening a Can of Worms

**Script (~120 words, ~60 sec):**

> Result two: a finding I'll call "opening a can of worms."
>
> We took the full reasoning trace from a midterm proof and gave it to **gpt-5.4** — the strongest available model. Three different prompts: **naive**, **directed**, and **atomic-format**. Critically, the trace explicitly contains the words **"by pigeonhole."**
>
> All three responses paraphrase the technique — "directional projection," "discrete partitioning," "choose a direction." But **none names "pigeonhole."** The model paraphrases the *application*; it doesn't surface the *principle*.
>
> That's a categorical gap, not a prompting deficit. Recovering an edge from a problem to related problems — let alone to the abstract hub — is hard for the digest in ways prompting alone won't fix.

**Pacing tips:**
- Pause briefly after "**by pigeonhole**" — let the audience see the words on the slide. That's the dramatic beat.
- The "three prompts, zero pigeonhole" framing on the slide is the punchline — paraphrase it: *"None of them names 'pigeonhole.'"* with emphasis.
- "Categorical gap" is the sticky take-home phrase. Slow down on it.
- Don't read the long quoted responses on the slide — let the audience read while you summarize ("they all paraphrase the technique").
- Total slide time ≈ 60 sec.

**Tighter alternative (~100 words):**

> Result two: opening a can of worms. We took a midterm proof's reasoning trace and gave it to **gpt-5.4** — the strongest available model. Three different prompts — naive, directed, atomic-format. Critically, the trace explicitly says **"by pigeonhole."** All three responses paraphrase the technique — "directional projection," "discrete partitioning," "choose a direction" — but none names "pigeonhole." The model paraphrases the application; it doesn't surface the principle. That's a categorical gap, not a prompting deficit — and it blocks the digest from recovering edges to related problems, let alone the hub.

---

## Slide 7 — Result 3: Sorry-with-Witness

**Script (~120 words, ~60 sec):**

> Result three: the **sorry-with-witness** pattern.
>
> Recall the midterm averaging proof had three sorry's. One is a definite integral — the integral of max(cos u, 0) from 0 to 2π equals 2.
>
> In pure Lean, closing it requires FTC, integral splitting at the zero of cos, periodicity — a substantial bespoke proof. In sympy: **four lines, returns 2 instantly**.
>
> The reframe: **decompose work by tool**. Each tool is a dense information sink. We accept the sorry in Lean because a trusted external tool independently verified the claim.
>
> And this leads naturally to the next slide: if we can decompose work by tool, can we also decompose by **model capability** — planning, reasoning, coding, formalization?

**Pacing tips:**
- Contrast the two approaches with vocal rhythm: pause after "substantial bespoke proof," then quicker delivery of "**four lines, returns 2 instantly**." The punch is the contrast.
- "Decompose work by tool" / "dense information sink" is the headline phrase — slow down on it.
- The closing transition is a *bridge* into slide 8 — make eye contact, advance immediately. Don't dwell on slide 7's bottom strip; the audience already read it.
- Total slide time ≈ 60 sec.

**Tighter alternative (~95 words):**

> Result three: the **sorry-with-witness** pattern. The midterm averaging proof had three sorry's. One is a definite integral — the integral of max(cos u, 0) from 0 to 2π equals 2. In pure Lean, closing it requires FTC, integral splitting, periodicity — substantial bespoke work. In sympy: **four lines, returns 2 instantly**. The reframe: **decompose work by tool**. Each tool is a dense information sink. We accept the sorry because the tool independently verified the claim. And that suggests the next question: can we also decompose by **model capability**?

---

## Slide 8 — Result 4: Ablation

**Script (~140 words, ~65 sec):**

> Result four: the ablation. Same problem — proving the harmonic sequence diverges in Lean — same K-shot retry protocol.
>
> **Opus 4.7, three rounds, succeeded.** Round one: mechanical syntax fix. Round two: a real insight — `funext` to lift pointwise equality to function equality. Round three: clean compile.
>
> **gpt-5.4-mini, ten rounds, failed.** Started at 13 errors, dropped to 1 by round four — then plateaued for six rounds. But here's the surprise: by round four, the weak model had **the same strategy as Opus** — same `funext` insight, same Mathlib lemma, same contradiction step. The flow was right. What it couldn't do was close the inductive bridge at the tactic level.
>
> **Takeaway:** capability decomposes. Weak matches strong on **planning and reasoning**; weak fails at **formalization** — the coding side. Implication: cheap model — about six times cheaper — for planning and reasoning; strong reserved for tactic-level coding.

**Pacing tips:**
- The 3-round strong result is rapid-fire — match each round to a step ("Round one… Round two… Round three…") and don't dwell.
- The "dropped to 1 by round four — then plateaued" needs a beat. The plateau is the surprise, not the failure itself.
- "**The same strategy as Opus**" is the key reveal — slow down. Audience may have expected weak to fail by being dumb; the actual story is more nuanced.
- The closing implication ("cheap model for planning and reasoning; strong reserved for coding") is the **architectural takeaway** of the entire talk. Land it slowly, advance immediately into slide 9.
- Total slide time ≈ 65 sec.

**Tighter alternative (~110 words):**

> Result four: the ablation. Same problem — proving the harmonic sequence diverges in Lean — same K-shot retry protocol. **Opus 4.7, three rounds, succeeded:** mechanical syntax fix, then a `funext` insight, then clean compile. **gpt-5.4-mini, ten rounds, failed:** dropped from 13 errors to 1 by round four, then plateaued. The surprise: by round four, the weak model had **the same strategy as Opus** — same `funext` insight, same Mathlib lemma, same contradiction step. What it couldn't do was close the inductive bridge at the tactic level. **Takeaway:** capability decomposes. Weak matches strong on planning and reasoning; weak fails at formalization. Cheap model for planning + reasoning; strong reserved for coding.

---

## Slide 9 — Future Work

**Script (~115 words, ~55 sec):**

> To close — future work, organized two ways.
>
> **From the midterm**: sympy integration is **done**, with improvement shown today. Formalized dataset curation is **in progress at 105 of 455 notes** — pushing further would have cost more usage budget than I had this week. The digest agent — **attempted**, and that's where we observed the categorical gap. Full-scale evaluation is **blocked** on the digest being unreliable.
>
> **Going forward**, two tracks. **Scaling already-built infrastructure**: sympy-witness across more proofs, ablation across more problems and weak models, digest probe to quantify the categorical gap at scale. **New directions**: atomic analysis as a stricter digest standard, reasoning arbitration for proactive tool delegation, and broader tool integration — OR-Tools, Z3.
>
> Thanks — happy to take questions.

**Pacing tips:**
- The "done / in-progress / attempted / blocked" framing on the midterm items is **honest** and reads as disciplined research. Don't rush through it — these four words land best with brief beats.
- The "ran out of usage budget this week" is the framing for *why* full scaling didn't happen. State it matter-of-factly — it's a real constraint, not an excuse.
- "Two tracks" mirrors the slide structure (left column / right column). Number them verbally.
- "Thanks — happy to take questions" is the natural close. Make eye contact, don't fade out, advance slightly off the slide if the deck is still showing.
- Total slide time ≈ 55 sec.

**Tighter alternative (~95 words):**

> Future work, two ways. **From the midterm**: sympy integration done; dataset curation in progress at 105 of 455 — limited by usage budget; digest agent attempted, where we observed the categorical gap; full-scale evaluation blocked on the digest. **Going forward**, two tracks. **Scaling**: sympy-witness across more proofs, ablation matrix expanded, digest probe at scale. **New directions**: atomic analysis as a stricter digest standard, reasoning arbitration for proactive delegation, broader tool integration — OR-Tools, Z3. Thanks — happy to take questions.
