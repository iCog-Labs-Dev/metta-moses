;; ---------------------------------------------------------------------------
;; Probe 2 (zipform Phase 1, probe gate). Columns as cons-lists of True/False
;; (surface True/False parse to native lowercase grounded booleans, per prior
;; probing). Verifies:
;;   (a) (List.zipWith and colA colB) / (List.zipWith or colA colB) apply the
;;       builtin `and`/`or` var-headed (List.zipWith's body is `($f $x $y)`,
;;       common/list-helpers.metta:31-32) and give the correct columns.
;;   (b) a unary map negates a column correctly two ways: `(map-atom $col $v
;;       (not $v))` (builtin `not` written directly) AND the fully
;;       var-headed form `($f $v)` with $f bound to `not` at runtime.
;; Both runtimes (PeTTaV1 -s, PeTTa-pr165).
;; ---------------------------------------------------------------------------

!(import! &self ../common/list-helpers)

;; --- fixture columns ---------------------------------------------------
(= (colA) (cons True (cons False (cons True (cons False ())))))
(= (colB) (cons True (cons True (cons False (cons False ())))))

;; --- expected results (hand-computed truth table) -----------------------
;; colA:      True  False True  False
;; colB:      True  True  False False
;; colA&colB: True  False False False
;; colA|colB: True  True  True  False
;; not colA:  False True  False True
(= (expectedAnd) (cons True (cons False (cons False (cons False ())))))
(= (expectedOr)  (cons True (cons True  (cons True  (cons False ())))))
(= (expectedNot) (cons False (cons True (cons False (cons True ())))))

;; --- unary map, two ways --------------------------------------------------
;; Direct: `not` written literally as the applied op.
(= (colNotDirect $col) (map-atom $col $v (not $v)))
;; Var-headed: $f bound to `not` at runtime, applied via ($f $v).
(= (colNotViaVar $f $col) (map-atom $col $v ($f $v)))

;; =====================  Assertions  =========================================
!(println! (AND_RESULT (List.zipWith and (colA) (colB))))
!(test (List.zipWith and (colA) (colB)) (expectedAnd))

!(println! (OR_RESULT (List.zipWith or (colA) (colB))))
!(test (List.zipWith or (colA) (colB)) (expectedOr))

!(println! (NOT_DIRECT_RESULT (colNotDirect (colA))))
!(test (colNotDirect (colA)) (expectedNot))

!(println! (NOT_VIAVAR_RESULT (colNotViaVar not (colA))))
!(test (colNotViaVar not (colA)) (expectedNot))

;; direct vs var-headed must agree
!(test (colNotViaVar not (colA)) (colNotDirect (colA)))
