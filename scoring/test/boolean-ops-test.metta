!(import! &self ../../utilities/general-helpers)
;; scoring/fitness publishes the table through the parameter registry, so bind
;; &params and import the registry before it.
!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)
!(import! &self ../cacheSpace)
!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)

;; Native boolean evaluation for the columnar engine. The operator SEMANTICS
;; live in the AND/OR/NOT clauses (boolean-ops.metta). evalTree (fitness.metta)
;; compiles a candidate Tree into a column term with rewriteTree, and
;; evalSubtree walks that term: each sub-term gives one per-row column.
;;
;; This file imports boolean-ops, so a bare (AND ...)/(OR ...)/(NOT ...) DATA
;; literal at a call site compiles as a CALL into the clauses -- data sites are
;; quote-guarded, and expected wrapped values are written under quote too.

;; Whole-column evaluator built from the production pieces: buildTree ->
;; evalTree over the shared 4-row table -> the candidate's per-row column.
;; Mirrors feat's callBE (candTemplate/evalParsed), which do not exist in the
;; merged engine; here the same behavior is exercised through the columnar path.
;;
;; The scoring memo is keyed by the column term and is valid only for ONE table.
;; evalTree empties it when the table changes, but this section uses the SAME
;; 4-row table (t4Cols/t4Labs) for every candidate. Columns of A B C D:
;;   A=(T T F F) B=(T F T F) C=(T F F T) D=(T F T F)
;; t4Cols is the COLUMN-major payload; t4Rows is the same data row-major, for
;; the legacy per-row path below.
(= (t4Cols) ((True True False False) (True False True False) (True False False True) (True False True False)))
(= (t4Rows) ((True True True True) (True False False False) (False True False True) (False False True False)))
(= (t4Labs) (A B C D))
(= (colE $cand)
   (evalTree (buildTree $cand) (mkITable (t4Cols) (t4Labs))))
;; Legacy per-row column via the old evaluate/replaceVarsWithTruth path (parity).
(= (legacyColE $cand)
   (map-atom (t4Rows) $r (evaluate (replaceVarsWithTruth ((t4Labs) $cand) $r))))

;; ---- AND / OR (wrapped-list, single arity-1 clause = n-ary) ----
;; These are intentional direct calls into the eval clauses (verbatim from feat).
!(assertEqual (AND (True True True))               True)
!(assertEqual (AND (True False True))              False)
!(assertEqual (AND ())                             True)
!(assertEqual (OR  (False False True))             True)
!(assertEqual (OR  (False False))                  False)
!(assertEqual (OR  ())                             False)
;; Higher arity (well beyond what manual enumeration would cover) -- one clause
;; handles it because the children ride in as a single Expression.
!(assertEqual (AND (True True True True True True True True True True)) True)
!(assertEqual (AND (True True True True True True True True True False)) False)

;; ---- NOT (same wrapped argument list as AND/OR) ----
!(assertEqual (NOT (True))  False)
!(assertEqual (NOT (False)) True)
!(assertEqual (NOT ((NOT (True))))  True)
!(assertEqual (NOT ((NOT (False)))) False)

;; ---- rewriteTree: Tree -> column term (was preOrderExp / childrenExp) ----
;; A leaf label becomes its column reference; a nullary AND/OR becomes its
;; identity constant (mempty), which evalSubtree broadcasts over the rows.
;; Expected terms are quoted: col/mapOp/zipOp are live heads here.
!(let $exp (quote (col A)) (assertEqual (rewriteTree (mkTree (mkNode A) ())) $exp))
!(assertEqual (rewriteTree (mkTree (mkNode AND) ())) True)
!(assertEqual (rewriteTree (mkTree (mkNode OR)  ())) False)
!(let* (($cand (quote (AND A B))) ($exp (quote (zipOp AND (col A) (col B)))))
   (assertEqual (rewriteTree (buildTree $cand)) $exp))
!(let* (($cand (quote (NOT A))) ($exp (quote (mapOp NOT (col A)))))
   (assertEqual (rewriteTree (buildTree $cand)) $exp))
!(let* (($cand (quote (OR (AND A B) C)))
        ($exp (quote (zipOp OR (zipOp AND (col A) (col B)) (col C)))))
   (assertEqual (rewriteTree (buildTree $cand)) $exp))
;; Child mapping (was childrenExp): the operator clause maps rewriteTree over
;; the child Trees in order and drops a null knob, so the SURVIVING count (2)
;; selects the binary zipOp form. Raw ADT: buildTree makes no knobs.
!(let* (($children (cons (mkTree (mkNode A) ())
                         (cons (mkKnob (mkNullVex (cons (mkTree (mkNode C) ()) ())) lsk 0)
                               (cons (mkTree (mkNode B) ()) ()))))
        ($exp (quote (zipOp AND (col A) (col B)))))
   (assertEqual (rewriteTree (mkTree (mkNode AND) $children)) $exp))

;; ---- Row application: zipOp/mapOp/zipWithN call the WRAPPED clause per row ----
!(assertEqual (zipOp AND (True True False) (True False False)) (True False False))
!(assertEqual (zipOp OR (False False True) (False True True))  (False True True))
!(assertEqual (mapOp NOT (True False)) (False True))
;; One wrapped clause per op, so each row gives ONE solution.
!(assertEqual (collapse (mapOp NOT (True False))) ((False True)))
;; zipWithN applies the wrapped clause to one row tuple.
!(assertEqual (zipWithN AND ((True False) (True True) (True True))) (True False))

;; transposeCols: list of equal-length columns -> per-row value tuples.
!(assertEqual (transposeCols ((True True True) (False False False)))
              ((True False) (True False) (True False)))

;; ---- End-to-end columns via colE over the shared 4-row table (replaces feat
;; callBE + per-row-freshness; each candidate is evaluated ONCE). ----
;; Unary NOT: NOT A over A=(T T F F) = (F F T T).
!(assertEqual (colE (quote (NOT A))) (False False True True))
;; Binary AND / OR truth-table coverage (whole column).
!(assertEqual (colE (quote (AND A B))) (True False False False))
!(assertEqual (colE (quote (OR A B)))  (True True True False))
;; Three-label nested: (OR A B)=(T T T F), (NOT C)=(F T T F) -> AND = (F T T F).
!(assertEqual (colE (quote (AND (OR A B) (NOT C)))) (False True True False))
;; N-ary, 4 children, one clause: A&B&C&D = (T F F F).
!(assertEqual (colE (quote (AND A B C D))) (True False False False))
;; Repeated label (both leaves index column A) -> (T T F F).
!(assertEqual (colE (quote (AND A A))) (True True False False))

;; ---- Parity with the legacy `evaluate` path (same table, column-wise) ----
!(let $cand (quote (OR (AND A (NOT B)) C))
   (assertEqual (colE $cand) (legacyColE $cand)))
!(let $cand (quote (AND (OR A B) (OR C D)))
   (assertEqual (colE $cand) (legacyColE $cand)))
