import Mathlib

theorem linearMap_trace_comp_comm
    {K V : Type*}
    [Field K]
    [AddCommGroup V]
    [Module K V]
    [Module.Free K V]
    [Module.Finite K V]
    (A B : Module.End K V) :
    LinearMap.trace K V (A.comp B) = LinearMap.trace K V (B.comp A) := by
  sorry

theorem linearMap_trace_linear_combination
    {K V : Type*}
    [Field K]
    [AddCommGroup V]
    [Module K V]
    [Module.Free K V]
    [Module.Finite K V]
    (A B : Module.End K V)
    (a b : K) :
    LinearMap.trace K V (a • A + b • B) =
      a * LinearMap.trace K V A + b * LinearMap.trace K V B := by
  sorry