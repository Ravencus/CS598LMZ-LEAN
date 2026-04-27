import Lake
open Lake DSL

package "LeanProver" where
  leanOptions := #[
    ⟨`pp.unicode.fun, true⟩
  ]

require mathlib from git
  "https://github.com/leanprover-community/mathlib4.git"

@[default_target]
lean_lib «Scratch» where
  srcDir := "Scratch"
