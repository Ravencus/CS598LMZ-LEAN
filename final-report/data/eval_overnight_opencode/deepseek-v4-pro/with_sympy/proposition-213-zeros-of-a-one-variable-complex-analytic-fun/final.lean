import Mathlib

-- Test 1: how to get AnalyticAt from AnalyticOn + open set
example (U : Set ℂ) (f : ℂ → ℂ) (z0 : ℂ) (h_open : IsOpen U)
    (h_analOn : AnalyticOn ℂ f U) (hz0U : z0 ∈ U) : AnalyticAt ℂ f z0 := by
  exact h_analOn.analyticAt h_open hz0U

-- Test 2: what lemma gives isolation of zeros?
#check AnalyticAt.eq_zero_or_eventually_ne_zero
#check AnalyticAt.eventually_eq_zero_or_eventually_ne_zero
#check AnalyticAt.eq_zero_or_eventually_nhds_ne_zero
#check HasFPowerSeriesAt.eq_zero_or_eventually_ne_zero
#check HasFPowerSeriesAt.eventually_eq_zero_or_eventually_ne_zero
#check AnalyticAt.locally_ne_zero