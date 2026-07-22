;; Probe: does evaluator-common's zipWithN branch (transposeCols in
;; particular) correctly handle a NULLARY op node `(zipWithN AND ())`, given
;; production-style all/any local defs? transposeCols's own doc comment
;; says it assumes "non-empty equal-length columns" -- a nullary op passes
;; ZERO columns, a structurally different case, so this must be verified
;; directly rather than assumed.
!(bind! &params (new-space))
!(import! &self ../../../parameters/registry)
!(import! &self ../common/list-helpers)
!(import! &self ../common/kernel-common)
!(import! &self ../zipform/evaluator-common)

(= (all $args) (foldl-atom $args True $acc $x (and $acc $x)))
(= (any $args) (foldl-atom $args False $acc $x (or $acc $x)))
(= (AND $args) (all $args))
(= (OR $args) (any $args))

!(setZipTable (mkITable ((False False) (True True)) (A Out)))
!(println! (TRANSPOSE_EMPTY (transposeCols ())))
!(println! (NULLARY_AND (evalZipTermCore (quote (zipWithN AND ())) evalZipTermCore)))
!(println! (NULLARY_OR (evalZipTermCore (quote (zipWithN OR ())) evalZipTermCore)))
