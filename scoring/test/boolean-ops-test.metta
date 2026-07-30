!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)
!(import! &self ../cacheSpace)
!(import! &self ../fitness)
!(import! &self ../boolean-ops)
!(import! &self ../bscore)

;; Native boolean evaluation for the MERGED columnar engine. The operator
;; SEMANTICS live in the AND/OR/NOT clauses (boolean-ops.metta); scoreTree turns
;; a candidate Tree into the wrapped eval shape with preOrderExp and evalSubtree
;; (fitness.metta) evaluates each subtree ONCE into a per-row column: on a cache
;; miss it builds the node's shared-var template once (mkNodeTemplate), then per
;; row seals/freshens the vars, unifies them against the row's child values, and
;; reduce-dispatches the clause (evalRow).
;;
;; This file imports boolean-ops, so a bare (AND ...)/(OR ...)/(NOT ...) DATA
;; literal at a call site compiles as a CALL into the clauses -- data sites are
;; quote-guarded, and expected wrapped values are written under quote too.

;; Whole-column evaluator built from the production pieces: preOrderExp ->
;; evalSubtree over the shared 4-row table -> the candidate's per-row column.
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
   (evalSubtree (preOrderExp (buildTree $cand)) (mkITable (t4Rows) (t4Labs)) 4))
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

;; ---- preOrderExp / childrenExp: Tree -> wrapped eval shape ----
;; leaf label stays a symbol; nullary AND/OR becomes its identity (Op ()).
!(assertEqual (preOrderExp (mkTree (mkNode A) ())) A)
!(let $exp (quote (AND ())) (assertEqual (preOrderExp (mkTree (mkNode AND) ())) $exp))
!(let $exp (quote (OR ()))  (assertEqual (preOrderExp (mkTree (mkNode OR)  ())) $exp))
!(let* (($cand (quote (AND A B))) ($exp (quote (AND (A B)))))
   (assertEqual (preOrderExp (buildTree $cand)) $exp))
!(let* (($cand (quote (NOT A))) ($exp (quote (NOT (A)))))
   (assertEqual (preOrderExp (buildTree $cand)) $exp))
!(let* (($cand (quote (OR (AND A B) C))) ($exp (quote (OR ((AND (A B)) C)))))
   (assertEqual (preOrderExp (buildTree $cand)) $exp))
;; childrenExp maps preOrderExp over child Trees.
!(let* (($children (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ($exp (quote (A B))))
   (assertEqual (childrenExp $children) $exp))

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
