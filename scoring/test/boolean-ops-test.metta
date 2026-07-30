!(import! &self ../../utilities/general-helpers)
;; ENTRY-FILE REQUIREMENT: scoring/fitness publishes the run's table through the
;; parameter registry, so a scoring entry file must bind &params and load the
;; registry first, else evalTree silently yields zero solutions.
!(bind! &params (new-space))
!(import! &self ../../parameters/registry)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)
!(import! &self ../cacheSpace)
!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)

;; Native boolean evaluation for the MERGED columnar engine. The operator
;; SEMANTICS live in the AND/OR/NOT clauses (boolean-ops.metta); scoreTree turns
;; a candidate Tree into a materialized column term with rewriteTree and
;; evalSubtree (fitness.metta) walks that term, evaluating each sub-term ONCE
;; into a per-row column. The LEGACY per-row primitives (mkNodeTemplate/evalRow)
;; are off the scoring path but still pinned below.
;;
;; This file imports boolean-ops, so a bare (AND ...)/(OR ...)/(NOT ...) DATA
;; literal at a call site compiles as a CALL into the clauses -- data sites are
;; quote-guarded, and expected wrapped values are written under quote too.

;; Whole-column evaluator built from the production pieces: buildTree ->
;; evalTree over the shared 4-row table -> the candidate's per-row column.
;; Mirrors feat's callBE (candTemplate/evalParsed), which do not exist in the
;; merged engine; here the same behavior is exercised through the columnar path.
;;
;; CRITICAL: &subtreeCache is keyed by the symbolic subtree expr and is valid
;; only for ONE fixed table (a run scores one table). So the whole end-to-end
;; section evaluates every candidate against the SAME 4-row table (t4Rows/t4Labs)
;; -- evaluating a shared subexpr (e.g. (OR A B)) against two different tables in
;; one file would return a stale cached column. Columns of A B C D over the rows:
;;   A=(T T F F) B=(T F T F) C=(T F F T) D=(T F T F)
(= (t4Rows) ((True True True True) (True False False False) (False True False True) (False False True False)))
(= (t4Labs) (A B C D))
(= (colE $cand)
   (evalTree (buildTree $cand) (mkITable (t4Rows) (t4Labs)) 4))
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

;; ---- rewriteTree: Tree -> materialized column term ----
;; A leaf label becomes its column reference; a nullary AND/OR becomes its
;; identity CONSTANT (mempty), which evalSubtree broadcasts over the rows.
;; Expected terms are quote-guarded -- col/fmap/zipWith are LIVE heads here.
!(let $exp (quote (col A)) (assertEqual (rewriteTree (buildTree (quote A))) $exp))
!(assertEqual (rewriteTree (buildTree (quote (AND)))) True)
!(assertEqual (rewriteTree (buildTree (quote (OR))))  False)
!(let* (($cand (quote (AND A B))) ($exp (quote (zipWith AND (col A) (col B)))))
   (assertEqual (rewriteTree (buildTree $cand)) $exp))
!(let* (($cand (quote (NOT A))) ($exp (quote (fmap NOT (col A)))))
   (assertEqual (rewriteTree (buildTree $cand)) $exp))
!(let* (($cand (quote (OR (AND A B) C)))
        ($exp (quote (zipWith OR (zipWith AND (col A) (col B)) (col C)))))
   (assertEqual (rewriteTree (buildTree $cand)) $exp))
;; Child mapping and null-knob filtering in one node: three declared children
;; with a null knob in the middle, so A and B map into the term in order, the
;; knob drops out, and the SURVIVING count (2) selects the binary zipWith branch.
;; raw ADT: buildTree cannot produce mkKnob/mkNullVex children.
!(let* (($children (cons (mkTree (mkNode A) ())
                         (cons (mkKnob (mkNullVex (cons (mkTree (mkNode C) ()) ())) (lsk) 0)
                               (cons (mkTree (mkNode B) ()) ()))))
        ($exp (quote (zipWith AND (col A) (col B)))))
   (assertEqual (rewriteTree (mkTree (mkNode AND) $children)) $exp))

;; ---- Per-row primitives: node template (built once) + sealed/unify/reduce ----
;; mkNodeTemplate mints one fresh unbound var per child (inline map-atom:
;; per-element copy_term freshens $v each time -- see fitness.metta). The
;; sharing asserts below also prove the node is BUILT inert: had the clause
;; fired at build time, the expr could not equal the quoted expected shape.
!(assertEqual (let ($vars $e) (mkNodeTemplate AND (c1 c2 c3)) (size-atom $vars)) 3)
;; mkNodeTemplate returns ($varsTerm $exprTerm) SHARING the vars: unifying the
;; vars-term against values makes the same values appear inside the expr.
!(let $exp (quote (AND (True False)))
   (assertEqual
     (let* ((($vars $e) (mkNodeTemplate AND (c1 c2)))
            ($vars (True False)))
       $e)
     $exp))
!(let $exp (quote (NOT (True)))
   (assertEqual
     (let* ((($vars $e) (mkNodeTemplate NOT (c1)))
            ($vars (True)))
       $e)
     $exp))
;; evalRow: sealed freshening + one-step positional unify + reduce dispatch.
;; Consecutive rows through the SAME template give independent correct results
;; -- proof the sealed copy leaves the template unbound between rows.
!(assertEqual
   (let $t (mkNodeTemplate AND (c1 c2))
     ((evalRow $t (True True)) (evalRow $t (True False))))
   (True False))
!(assertEqual
   (let $t (mkNodeTemplate OR (c1 c2))
     ((evalRow $t (False False)) (evalRow $t (False True))))
   (False True))
!(assertEqual
   (let $t (mkNodeTemplate NOT (c1))
     ((evalRow $t (True)) (evalRow $t (False))))
   (False True))
;; n-ary template: 5 children, one clause dispatches.
!(assertEqual
   (let $t (mkNodeTemplate AND (c1 c2 c3 c4 c5))
     ((evalRow $t (True True True True True)) (evalRow $t (True True False True True))))
   (True False))
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
