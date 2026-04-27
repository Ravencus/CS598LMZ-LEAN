**Proof Schemas**

1. **Sector / Pigeonhole proof for the stated `1/6` bound**

- **Problem**: For complex numbers `z₁, …, zₙ` with `∑ |zᵢ| = 1`, show there is a subset `S` such that `|∑_{i∈S} zᵢ| ≥ 1/6`.
- **Strategy**: Partition directions into `3` sectors of angle `2π/3`, use pigeonhole to find one sector carrying at least `1/3` of the total mass, then project onto that sector’s bisector.
- **Subgoals**:
  1. Partition the plane/circle into `3` sectors covering all vectors.
  2. Show one sector contains vectors with total modulus at least `1/3`.
  3. For vectors inside a `2π/3` sector, show projection onto the bisector is at least `|z| cos(π/3) = |z|/2`.
  4. Sum projections to get a real lower bound on the norm of the subset sum.
- **Key lemmas / facts**:
  - Pigeonhole principle on the three sector sums.
  - Projection inequality: if a vector makes angle at most `π/3` with a unit direction `u`, then `Re(conj(u) * z) ≥ |z|/2`.
  - Norm dominates any fixed-direction projection: `|w| ≥ Re(conj(u) * w)`.
- **Applicability conditions**:
  - Works in `ℝ²` / `ℂ`, where “direction” and “angle sector” are available.
  - Needs a norm and a projection-to-direction estimate.
  - Best suited when vectors can be grouped by angular concentration.
- **Common pitfalls**:
  - Using `2` sectors fails: a semicircle only gives boundary projection `cos(π/2)=0`.
  - Forgetting that the chosen subset is only the vectors in one sector, not all vectors.
  - Confusing “sum of norms” with “norm of total sum”; cancellation is the whole issue.

2. **Quadrant / coordinate-sign proof for the stronger `1/4` bound**

- **Problem**: Under the same hypothesis, prove a stronger statement: some subset satisfies `|∑_{i∈S} zᵢ| ≥ 1/4`.
- **Strategy**: Split vectors by the sign of their real and imaginary parts; one of the four sign-accumulations must be at least `1/4`, and choosing that sign-class gives the result.
- **Subgoals**:
  1. Define
     - `a = ∑ Re(zᵢ)` over `Re(zᵢ) ≥ 0`,
     - `b = ∑ |Re(zᵢ)|` over `Re(zᵢ) < 0`,
     - `c = ∑ Im(zᵢ)` over `Im(zᵢ) ≥ 0`,
     - `d = ∑ |Im(zᵢ)|` over `Im(zᵢ) < 0`.
  2. Show `a+b+c+d = ∑ (|Re zᵢ| + |Im zᵢ|)`.
  3. Use `|Re z| + |Im z| ≥ |z|` to get `a+b+c+d ≥ 1`.
  4. Conclude `max(a,b,c,d) ≥ 1/4`.
  5. If, say, `a ≥ 1/4`, take `S = {i : Re(zᵢ) ≥ 0}` and use `|∑_{i∈S} zᵢ| ≥ Re(∑_{i∈S} zᵢ)=a`.
- **Key lemmas / facts**:
  - Triangle inequality in coordinates: `|x| + |y| ≥ sqrt(x²+y²)`; equivalently `|Re z| + |Im z| ≥ |z|`.
  - Norm dominates real or imaginary part: `|w| ≥ |Re w|`, hence `|w| ≥ Re w` when `Re w ≥ 0`.
  - Max lower bound from a sum of four nonnegative terms.
- **Applicability conditions**:
  - Specific to a fixed coordinate decomposition in `ℝ²` / `ℂ`.
  - Works because there are exactly two coordinates and each yields a positive/negative split.
  - Useful when coordinatewise absolute values control the norm.
- **Common pitfalls**:
  - Overgeneralizing this as a dimension-free method; it is strongly `2D`/coordinate-dependent.
  - Choosing the wrong subset: the set must be tied to the sign that realizes the large term.
  - Forgetting the inequality goes through a projection (`Re` or `Im`), not directly from modulus sums.

3. **Averaging / probabilistic proof for the optimal `1/π` bound**

- **Problem**: Show the optimal guaranteed bound is `1/π`: there exists a subset `S` with `|∑_{i∈S} zᵢ| ≥ 1/π`.
- **Strategy**: Average over all directions. For each direction `α`, choose the subset of vectors with nonnegative projection onto that direction; the average positive projection is `1/π`, so some direction achieves at least that much.
- **Subgoals**:
  1. For each `α`, define `S_α = { i : proj_α(zᵢ) ≥ 0 }`.
  2. Let `F(α) = ∑ max(proj_α(zᵢ), 0)`.
  3. Compute for each vector:
     `∫₀^{2π} max(|zᵢ| cos(θᵢ-α), 0) dα = 2|zᵢ|`.
  4. Sum over `i` to get `∫₀^{2π} F(α) dα = 2`.
  5. Therefore the average of `F` is `1/π`, so some `α₀` has `F(α₀) ≥ 1/π`.
  6. Use `|∑_{i∈S_{α₀}} zᵢ| ≥ F(α₀)` via projection on direction `α₀`.
- **Key lemmas / facts**:
  - Linearity of the integral / finite-sum interchange.
  - Explicit integral `∫ max(cos t,0) dt = 2` over a full period.
  - Norm dominates directional projection.
- **Applicability conditions**:
  - Requires integration/measure machinery.
  - Best when a family of candidate subsets is naturally indexed by directions and one can average a lower bound.
  - Still fundamentally a `projection onto directions` argument; the continuous parameter is what sharpens the constant.
- **Common pitfalls**:
  - Proving only that the average of signed projections is `0`; the key object is the positive part.
  - Forgetting that the selected subset depends on `α`.
  - In Lean, this is much heavier than the discrete proofs because it needs real analysis infrastructure.

4. **Optimality example for `1/π`**

- **Problem**: Show `1/π` cannot be improved in general.
- **Strategy**: Use many equal vectors uniformly spaced on the unit circle; the best subset asymptotically behaves like a semicircle.
- **Subgoals**:
  1. Construct `n` vectors `z_k = e^{iθ_k}/n` with nearly uniform `θ_k`.
  2. Argue the best subset is asymptotically a half-circle selection.
  3. Compute the limiting sum by an integral and get `1/π`.
- **Key lemmas / facts**:
  - Riemann-sum / equidistribution intuition.
  - Integral of `e^{iθ}` over `[-π/2, π/2]`.
- **Applicability conditions**:
  - For sharpness / extremal analysis, not for existence proofs alone.
- **Common pitfalls**:
  - Treating the finite-`n` configuration as exactly equal to the limit without justification.
  - Assuming the extremal subset is obvious without a symmetry argument.

**Failure Lessons**

1. **Stuck pattern**: Trying too few angular sectors (`k=2`) in the sector method.
- **Error**: No explicit Lean diagnostic in the trace; mathematically the bound collapses to `0`.
- **Likely cause**: The projection loss is `cos(π/k)`, so for `k=2` the boundary case gives `cos(π/2)=0`.
- **Resolution**: Increase to at least `3` sectors, or change methods entirely.
- **Next strategy**: If a projection argument gives a zero boundary constant, refine the partition or switch to coordinate/averaging methods.
- **Tool boundary note**: Discrete sector partitioning has a built-in concentration/alignment tradeoff; coarse partitions can be useless.

2. **Stuck pattern**: Treating the stated `1/6` bound as if it were likely optimal.
- **Error**: Not a tactic failure; a conceptual local optimum.
- **Likely cause**: Reverse-engineering from the problem statement can hide stronger structure.
- **Resolution**: Probe stronger constants (`1/4`, then `1/π`) and compare methods.
- **Next strategy**: Whenever a problem gives a specific constant, test whether the same setup supports stronger bounds.
- **Tool boundary note**: “Prove the stated claim” is not always the best search policy; bound exploration is often essential.

3. **Stuck pattern**: Assuming “take all vectors” or another fixed subset should work.
- **Error**: Small-case counterexample: `z₁=1/2`, `z₂=-1/2`; full sum is `0`.
- **Likely cause**: Ignoring cancellation.
- **Resolution**: Build the subset from a directional criterion.
- **Next strategy**: In vector-sum problems, test `n=2` first; if cancellation appears, expect a selection/projection argument.
- **Tool boundary note**: Any tactic or proof search that only simplifies the full sum misses the real combinatorial choice.

4. **Stuck pattern**: Overgeneralizing the quadrant proof.
- **Error**: No Lean message; the mathematical issue is false transfer.
- **Likely cause**: The proof uses `Re/Im` coordinates in a way that is special to `2D`.
- **Resolution**: Reinterpret the proof as a projection argument rather than a generic “split by signs” trick.
- **Next strategy**: For higher dimensions, use directional averaging or more invariant convex-geometric tools instead of raw coordinate signs.
- **Tool boundary note**: Coordinate-splitting proofs often formalize easily but may encode dimension-specific accidents.

5. **Stuck pattern**: Moving immediately to the optimal `1/π` proof in Lean.
- **Error**: No explicit diagnostic shown, but the trace notes this is the hardest to formalize.
- **Likely cause**: The proof needs integration, periodicity, measurable positive-part functions, and sum/integral interchange.
- **Resolution**: Use the `1/6` or `1/4` discrete proof if the formalization goal is just the original existence theorem.
- **Next strategy**: In Lean, prefer the weakest proof that matches the target theorem unless optimality is required.
- **Tool boundary note**: Continuous averaging arguments have a much higher formalization cost than finite pigeonhole/projection arguments.

6. **Stuck pattern**: Summarizing the quadrant proof as “split by coordinate signs” and reusing that blindly.
- **Error**: Conceptual misclassification rather than a Lean error.
- **Likely cause**: Focusing on surface syntax instead of the invariant core idea.
- **Resolution**: The transferable principle is: choose a direction, take vectors with nonnegative projection, and lower-bound the resulting sum by accumulated projection.
- **Next strategy**: When extracting lessons, identify whether the proof is really about coordinates, order, convexity, projection, or averaging.
- **Tool boundary note**: This is exactly where tactic-level replay is weak; it preserves steps, not the right abstraction.

**Transferable Meta-Lesson**

The reusable backbone across all successful approaches is not “complex numbers” and not even “quadrants”; it is:

- choose a direction or a family of directions,
- select vectors with favorable projection,
- convert a projection lower bound into a norm lower bound,
- optimize how much mass can be aligned with that direction.

That principle supports the discrete `1/6` proof, the coordinate `1/4` proof, and the averaged optimal `1/π` proof.