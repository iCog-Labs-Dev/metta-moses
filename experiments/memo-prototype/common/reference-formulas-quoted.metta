;; ---------------------------------------------------------------------------
;; reference-formulas-quoted.metta -- variant G ("generic ops") twin of
;; common/reference-formulas.metta. IDENTICAL tables and hand-computed
;; expected columns; the ONLY difference is that every formula BODY that
;; mentions AND/OR/NOT is wrapped in `quote`. Variant G's zipform/ops-generic
;; .metta gives AND/OR/NOT real clauses, so an unquoted body like
;; `(AND (A B))` would compile to a grounded `partial('AND',[[A,B]])` at
;; translation time (see ops-generic.metta's header) and never reach the
;; rewriter as clean data. Calling a quoted body evaluates the `quote` and
;; yields the clean wrapped-node expression the rewriter expects.
;;
;; Expected columns are plain boolean literals (no AND/OR/NOT), so they need
;; no quoting and are copied verbatim from reference-formulas.metta.
;; ---------------------------------------------------------------------------

;; --- Tiny 4-row, 2-variable reference table (verbatim) --------------------
;;   A column = (False False True True) ; B column = (False True False True)
(= (miniTable)
   (mkITable
     ((False False False) (False True True) (True False True) (True True False))
     (A B Out)))

;; --- Formula 1: single label leaf (bare symbol -- no AND/OR/NOT, no quote) -
(= (formulaLeafA) A)
(= (expectedLeafA) (False False True True))

;; --- Formula 2: (NOT (A)) --------------------------------------------------
(= (formulaNotA) (quote (NOT (A))))
(= (expectedNotA) (True True False False))

;; --- Formula 3: (AND (A B)) ------------------------------------------------
(= (formulaAndAB) (quote (AND (A B))))
(= (expectedAndAB) (False False False True))

;; --- Formula 4: (OR (A B)) -------------------------------------------------
(= (formulaOrAB) (quote (OR (A B))))
(= (expectedOrAB) (False True True True))

;; --- Formula 5: nested (AND ((OR (A B)) (NOT (B)))) ------------------------
(= (formulaNestedAndOrNot) (quote (AND ((OR (A B)) (NOT (B))))))
(= (expectedNestedAndOrNot) (False False True False))

;; --- Formula 6: full parity3 formula (XOR expansion over X1..X3) ----------
(= (parity3Formula)
   (quote
     (OR ( (AND (X1 (NOT (X2)) (NOT (X3))))
           (AND ((NOT (X1)) X2 (NOT (X3))))
           (AND ((NOT (X1)) (NOT (X2)) X3))
           (AND (X1 X2 X3)) ))))
(= (expectedParity3Formula)
   (False True True False True False False True))
