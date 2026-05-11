1. Rewrite `tan(π/4 + 1/n)` using the tangent addition formula as `(1 + tan(1/n)) / (1 - tan(1/n))`, and note that for large `n` this quantity is positive so the natural log representation of the power is valid.

2. Show that `tan(1/n) → 0` and, more sharply, that `n * tan(1/n) → 1` as `n → ∞`.

3. Prove the logarithmic asymptotic
   `n * log((1 + tan(1/n)) / (1 - tan(1/n))) → 2`,
   using the expansion `log((1+x)/(1-x)) ~ 2x` near `x = 0`.

4. Convert the power to an exponential via `a^n = exp(n * log a)` for positive `a`, so the sequence becomes `exp` of the expression from step 3.

5. Apply continuity of `exp` to conclude the limit is `exp 2`.