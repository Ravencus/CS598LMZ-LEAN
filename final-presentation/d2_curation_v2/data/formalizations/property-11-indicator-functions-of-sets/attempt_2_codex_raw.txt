import Mathlib

open scoped Topology Pointwise
open MeasureTheory

universe u

theorem indicator_set_identities (X : Type u) (A B : Set X) :
    (∀ x : X,
      Set.indicator (A ∩ B) (fun _ => (1 : ℤ)) x =
        Set.indicator A (fun _ => (1 : ℤ)) x * Set.indicator B (fun _ => (1 : ℤ)) x) ∧
    (∀ x : X,
      Set.indicator (A ∪ B) (fun _ => (1 : ℤ)) x =
        Set.indicator A (fun _ => (1 : ℤ)) x +
          Set.indicator B (fun _ => (1 : ℤ)) x -
            Set.indicator A (fun _ => (1 : ℤ)) x * Set.indicator B (fun _ => (1 : ℤ)) x) ∧
    (∀ x : X,
      Set.indicator Aᶜ (fun _ => (1 : ℤ)) x =
        1 - Set.indicator A (fun _ => (1 : ℤ)) x) ∧
    (∀ x : X,
      Set.indicator (A \ B) (fun _ => (1 : ℤ)) x =
        Set.indicator A (fun _ => (1 : ℤ)) x *
          (1 - Set.indicator B (fun _ => (1 : ℤ)) x)) ∧
    (∀ x : X,
      Set.indicator ((A \ B) ∪ (B \ A)) (fun _ => (1 : ℤ)) x =
        Set.indicator A (fun _ => (1 : ℤ)) x +
          Set.indicator B (fun _ => (1 : ℤ)) x -
            2 * (Set.indicator A (fun _ => (1 : ℤ)) x * Set.indicator B (fun _ => (1 : ℤ)) x)) := by
  sorry

theorem indicator_convolution_support_subset_closure_add
    (A B : Set ℝ) (μ : Measure ℝ) :
    Function.support
        (fun x : ℝ =>
          ∫ y, Set.indicator A (fun _ => (1 : ℝ)) y *
            Set.indicator B (fun _ => (1 : ℝ)) (x - y) ∂μ) ⊆
      closure (A + B) := by
  sorry