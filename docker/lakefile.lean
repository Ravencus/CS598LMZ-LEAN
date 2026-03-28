import Lake
open Lake DSL

package "LeanProver" where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩
  ]

require "leanprover-community" / "mathlib"

@[default_target]
lean_lib «Scratch» where
  srcDir := "Scratch"
