;; ---------------------------------------------------------------------------
;; GATE PROBE (zipform op-name-conversion-layer removal). Do NOT delete
;; zipform/ops.metta's rowFnTable/rowFnOfScan/rowFnOf, nor touch zipform/
;; rewriter.metta, until this probe passes on BOTH runtimes.
;;
;; The planned replacement: the rewriter will emit the tree's own op symbols
;; verbatim into materialized zip terms (e.g. `(zipWith AND (col x) ...)`
;; instead of `(zipWith and (col x) ...)`), relying on ordinary delegating
;; definitions to resolve AND/OR to the builtins:
;;   (= (AND $a $b) (and $a $b))
;;   (= (OR  $a $b) (or  $a $b))
;; List.zipWith applies `($f $x $y)` var-headed, so $f = AND dispatches this
;; clause -> builtin and.
;;
;; THE RISK this probe gates: every candidate the pipeline scores is a
;; WRAPPED node `(OP ($c1 .. $ck))` -- literally an OP applied to ONE
;; argument (a children-list), regardless of how many logical children $ck
;; there are. So `(AND (x (OR (y z))))` is AND applied to a SINGLE argument
;; -- an arity-1 application in raw MeTTa terms -- even though it "looks
;; binary" by eye. If AND/2's delegating clause above ever fired on that
;; arity-1 shape (or corrupted it during the whole-file live-head prescan
;; documented in probe-zip-quote-unfired.metta), every stored/replayed
;; candidate literal would be silently destroyed. This probe verifies MeTTa's
;; per-arity clause dispatch keeps arity-1 occurrences completely inert while
;; arity-2 occurrences (the row-fn call site inside a materialized zipWith
;; term, and List.zipWith's own var-headed `($f $x $y)` application) fire
;; correctly. NOT is deliberately EXCLUDED from this delegating-clause
;; treatment (see zipform/ops.metta's HOW-TO-ADD-AN-OP header after this
;; probe goes green): the wrapped candidate's unary shape `(NOT (c))` IS an
;; arity-1 application, so a delegating `(= (NOT $a) (not $a))` clause would
;; COLLIDE with candidate data instead of merely coexisting with it the way
;; AND/OR's arity-2 clauses do.
;; ---------------------------------------------------------------------------

!(import! &self ../common/list-helpers)

;; --- the delegating definitions under test (binary-only) -------------------
(= (AND $a $b) (and $a $b))
(= (OR  $a $b) (or  $a $b))

;; Independent oracles for the inertness checks, built via `quote` (never by
;; calling anything that could itself be live) -- same convention as probe-
;; zip-quote-unfired.metta's `expected`, so the tests below aren't tautologies.
(= (expectedInertCandidate) (quote (AND (x (OR (y z))))))
(= (expectedStoredCandidate) (quote (AND ((NOT (C)) B))))

;; =====================  Test 1: arity-1 inertness  ==========================
;; (AND (x (OR (y z)))) is AND applied to ONE argument (the children-list
;; (x (OR (y z)))) -- the real wrapped-candidate shape, not a hand-picked
;; edge case. AND/2's clause above requires exactly two arguments, so this
;; must stay completely inert: no reduction, no corruption.
!(println! (BARE_LITERAL (AND (x (OR (y z))))))
!(test (AND (x (OR (y z)))) (expectedInertCandidate))
!(test (get-metatype (AND (x (OR (y z))))) Expression)

;; Same candidate compared structurally against itself (not just against the
;; independent quoted oracle) -- belt and suspenders.
!(test (AND (x (OR (y z)))) (AND (x (OR (y z)))))

;; --- mirrors the replay-file load path (captures/*.replay.metta's own
;; `!(add-atom &replayStream (candidate $i $e))` convention) -- store a
;; candidate containing BOTH an arity-1 AND node and a NOT-wrapped child,
;; retrieve it back via `match`, and confirm it survived storage/retrieval
;; structurally intact.
!(bind! &arityProbeSpace (new-space))
!(add-atom &arityProbeSpace (candidate 1 (AND ((NOT (C)) B))))
!(let $stored (car-atom (collapse (match &arityProbeSpace (candidate 1 $e) $e)))
   (test $stored (expectedStoredCandidate)))

;; =====================  Test 2: var-headed zipWith dispatch  ================
;; List.zipWith's body is `($f $x $y)` (common/list-helpers.metta:31-32); with
;; $f = AND / $f = OR this must dispatch through the delegating clauses above
;; to the builtins and give the correct columns. Plain tuple fixtures (True/
;; False aren't live heads, so no `cons`/`quote` needed here).
(= (colA) (True False True False))
(= (colB) (True True False False))
(= (expectedAndCol) (True False False False))
(= (expectedOrCol)  (True True  True  False))

!(println! (ZIP_AND (List.zipWith AND (colA) (colB))))
!(test (List.zipWith AND (colA) (colB)) (expectedAndCol))

!(println! (ZIP_OR (List.zipWith OR (colA) (colB))))
!(test (List.zipWith OR (colA) (colB)) (expectedOrCol))

;; =====================  Test 3: arity-2 sanity (not vacuous)  ===============
;; Confirms the delegating definitions ARE live at their own arity -- i.e.
;; Test 1's inertness isn't just an artifact of AND/OR never firing at all.
!(println! (ARITY2_AND (AND True False)))
!(test (AND True False) False)

!(println! (ARITY2_OR (OR True False)))
!(test (OR True False) True)
