import Mathlib

open Filter

noncomputable def harmonicSeq (n : ℕ) : ℝ :=
  Finset.sum (Finset.Icc 1 n) fun k => (1 : ℝ) / (k : ℝ)

theorem harmonic_sequence_diverges :
    ¬ ∃ l : ℝ, Tendsto harmonicSeq atTop (nhds l) := by
  intro h
  rcases h with ⟨l, hl⟩
  have hconv : Tendsto harmonicSeq atTop (nhds l) := hl
  have hbounded : ∃ M : ℝ, ∀ n : ℕ, |harmonicSeq n| ≤ M := by
    rcases hconv.eventually_within with ⟨s, hs, hbound⟩
    have hne : (0 : ℝ) ≤ 1 := by positivity
    rcases hs with ⟨N, hN⟩
    refine ⟨max 0 (|l| + 1), ?_⟩
    intro n
    by_cases hn : n ≤ N
    · have hmem : n ∈ Set.Ici N := by
        exact le_trans hn (le_of_eq (Nat.le_of_lt_succ (Nat.lt_succ_self N)))
      have hle : |harmonicSeq n - l| < 1 := by
        have : harmonicSeq n ∈ Set.Ici N := by exact hmem
        exact hbound n this
      have htri : |harmonicSeq n| ≤ |l| + 1 := by
        have := abs_sub_le_iff.mpr (by linarith : harmonicSeq n - l ≤ 1 ∧ -(1 : ℝ) ≤ harmonicSeq n - l)
        linarith
      linarith
    · have hn' : N ≤ n := le_of_not_ge hn
      have hmem : n ∈ Set.Ici N := by exact hn'
      have hle : |harmonicSeq n - l| < 1 := by exact hbound n hmem
      have htri : |harmonicSeq n| ≤ |l| + 1 := by
        have := abs_sub_le_iff.mp (by linarith : |harmonicSeq n - l| ≤ 1)
        linarith
      linarith
  rcases hbounded with ⟨M, hM⟩
  have hmono : StrictMono harmonicSeq := by
    intro m n hmn
    unfold harmonicSeq
    have hsub : Finset.Icc 1 m ⊆ Finset.Icc 1 n := by
      intro k hk
      simp only [Finset.mem_Icc] at hk ⊢
      exact ⟨hk.1, le_trans hk.2 hmn⟩
    have hpos : 0 < ∑ x ∈ Finset.Icc 1 n \ Finset.Icc 1 m, (1 : ℝ) / (x : ℝ) := by
      have hnonempty : (Finset.Icc 1 n \ Finset.Icc 1 m).Nonempty := by
        rcases Nat.exists_lt_of_lt hmn with ⟨k, hk⟩
        refine ⟨k, ?_⟩
        simp [hk, Nat.lt_of_lt_of_le hk (Nat.le_of_lt_succ (Nat.lt_succ_self n))]
      refine Finset.sum_pos ?_ hnonempty
      intro x hx
      simp at hx
      positivity
    have hsum_eq :
        harmonicSeq n = harmonicSeq m + ∑ x ∈ Finset.Icc 1 n \ Finset.Icc 1 m, (1 : ℝ) / (x : ℝ) := by
      unfold harmonicSeq
      rw [← Finset.sum_union (by
        intro x hx1 hx2
        simp at hx1 hx2
        omega)]
      · rw [Finset.union_diff_cancel hsub]
      · exact Finset.disjoint_sdiff_right
    linarith
  have hunc : ¬ BoundedAbove (Set.range harmonicSeq) := by
    intro hb
    rcases hb with ⟨B, hB⟩
    have hB' : ∀ n, harmonicSeq n ≤ B := by
      intro n
      exact hB ⟨n, rfl⟩
    have hcontr := hM (Nat.succ (Nat.succ 0))
    have hlarge : ∀ n, harmonicSeq n ≤ B := hB'
    have hgrow : ∀ n, harmonicSeq (n + 1) > harmonicSeq n := by
      intro n
      have := hmono (n := n) (m := n + 1) (by omega)
      linarith
    have hstep : ∀ n, harmonicSeq n ≤ harmonicSeq 0 + n * (B - harmonicSeq 0) := by
      intro n
      induction n with
      | zero =>
          simp
      | succ n ih =>
          have hs : harmonicSeq (n + 1) ≤ B := hlarge (n + 1)
          have hgt : harmonicSeq (n + 1) > harmonicSeq n := hgrow n
          linarith
    have := hstep (Nat.succ (Nat.succ (Nat.succ 0)))
    linarith
  exact hunc (by
    rw [boundedAbove_iff_exists_ge]
    exact ⟨M, by intro x hx; exact hM x⟩)