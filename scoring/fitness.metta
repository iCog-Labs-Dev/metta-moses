
!(bind! &space (new-space))

(= (removeFromSpace $row $space) (remove-atom $space $row))

;  This function counts the total occurrences of variable $X in an expression non-deterministically.
;; (= (findX $expr $x)
;;     (if (== $expr ())
;;         (empty)
;;         (let $a (superpose $expr)
;;             (if (or (== (get-metatype $a) Grounded) (== (get-metatype $a) Symbol))
;;                 (if (== $a $x)
;;                     1
;;                     (empty)
;;                 )
;;                 (findX $a $x)
;;             )
;;         )
;;     )
;; )

(= (findX $expr $x)
   (if (once (is-member $x $expr))
       True
       (List.any (map-atom $expr $ex
             (if (or (== (get-metatype $ex) Grounded) (== (get-metatype $ex) Symbol))
                 (== $ex $x)
                 (findX $ex $x))))))

 ;; Replaces variables in an expression with their corresponding truth values from the space.
 ;; If a variable is not found, it is replaced with undefined.
(= (replaceWithTruth $expr $space $spaceContent)
    (if (== (get-metatype $expr) Expression) 
        (if (== (cdr-atom $expr) ()) ;; Special case: (A) → Should replace as a symbol
            (map-atom $expr $ex (replaceWithTruth $ex $space $spaceContent))
            (let* (
                ($op (car-atom $expr))
                ($tuple (cdr-atom $expr)) 
                ($substitutedArgs (map-atom $tuple $tp (replaceWithTruth $tp $space $spaceContent)))
                ($tupleWithOp (cons-atom $op $substitutedArgs))
            )
                $tupleWithOp
            )
        )
        (let $res (collapse (match $space ($expr $value) $value))
            (if (== $res ()) undefined $res)
        )
    )
)


 ;; A function to evaluateuate the boolean expression
 ;;     - If the input expression is a grounded value (True or False), it returns the value directly.
 ;;     - Otherwise, it extracts the operator from the expression and applies the corresponding evaluation function:
 ;;         - evaluateAnd for AND expressions
 ;;         - evaluateOr for OR expressions
 ;;         - not for NOT expressions
 ;;         - If the operator is unknown, it returns an error message.

(= (evaluate $expr)
    (if (== (get-metatype $expr) Grounded) ;; T / F
        $expr
        (if (== (cdr-atom $expr) ())  ;;  Handle (True) or (False)
            (evaluate (car-atom $expr))  ;; Extract the actual boolean value
            (case (car-atom $expr) 
                (
                    (AND (evaluateAnd (cdr-atom $expr)))
                    (OR (evaluateOr (cdr-atom $expr)))
                    (NOT (not (evaluate (cdr-atom $expr)))) 
                    ($_ ERROR)
                )
            )
        )
    )
)

 ;;  Evaluate OR subexpression
 ;;  Returns True if any argument evaluates to True, otherwise False.
(= (evaluateOr $args)
    (if (== $args ())
        False
        (let* 
          (
            ($first (car-atom $args))
            ($rest (cdr-atom $args))
          )
          (if (== (evaluate $first) True)
              True
              (evaluateOr $rest)
          )
        )
    )
)

 ;;  Evaluate AND subexpression
 ;;  Returns False if any argument evaluates to False, otherwise True.
(= (evaluateAnd $args)
    (if (== $args ())
        True
        (let* 
          (
            ($first (car-atom $args))
            ($rest (cdr-atom $args))
          )
          (if (== (evaluate $first) False)
              False
              (evaluateAnd $rest)
          )
        )
    )
)


;; ---------------------------------------------------------------------------
;; Columnar subtree evaluation over the wrapped preOrderExp shape:
;;   node = (AND (c1 .. ck)) / (OR (c1 .. ck)) / (NOT (c));  leaf = label | True/False
;; Every subtree is evaluated ONCE into a boolean column over all rows and
;; memoized in &subtreeCache, keyed by its ground wrapped expr (valid for the
;; run's single fixed table). Operator semantics live solely in the AND/OR/NOT
;; clauses (scoring/boolean-ops): on a cache miss a one-level template with
;; fresh shared vars is built once and every row is scored by unification --
;; sealed freshens the vars, a positional let binds the row's child values,
;; and one let-bound `reduce` dispatches the clause. A head with no clause
;; stays unreduced and scores worst (-1), like the old ERROR column.
;; Probes: tmp/probe-sealed.metta, tmp/probe-mapvars.metta.
;; ---------------------------------------------------------------------------

;; Extract a label's column from the row-major table. Unknown label -> loud
;; Error (malformed input); index-atom skips List.getByIdx's per-cell re-scan.
;(: varColumn (-> (ITable $a) Symbol (List Bool)))
(= (varColumn (mkITable $rows $labels) $label)
   (let $idx (List.index $labels $label)
        (if (== $idx -1)
            (Error $label "varColumn: label not found in table")
            (map-atom $rows $r (index-atom $r $idx)))))

;; Node row-template, built once per cache miss: ($varsTerm $exprTerm) sharing
;; fresh vars, e.g. (($v1 $v2) (AND ($v1 $v2))). map-atom's per-element
;; copy_term mints the k distinct vars; `cons` keeps the node inert (a bare
;; (AND ...) literal would fire the clause at build time).
(= (mkNodeTemplate $op $cvs)
   (let* (($vars (map-atom $cvs $c $v))
          ($e    (cons $op (cons $vars ()))))
     ($vars $e)))

;; One row through the template: sealed copies vars and expr together (the
;; template stays unbound for the next row), the let unifies the row's child
;; values positionally, and `reduce` dispatches the operator clause.
(= (evalRow $template $row)
   (let ($vars $e) $template
        (sealed $vars (let $vars $row (reduce $e)))))

;; Non-empty equal-length columns -> per-row value tuples (ground data only).
(= (transposeCols $cols)
   (if (== (car-atom $cols) ())
       ()
       (cons (map-atom $cols $c (car-atom $c))
             (transposeCols (map-atom $cols $c (cdr-atom $c))))))

;; Child columns -> node column: template once, then each transposed row
;; through evalRow via the var-safe map (map-atom would copy the template
;; per row). Childless AND/OR reduce their identity once and repeat it.
(= (combineNode $op $cvs $n)
   (if (== $cvs ())
       (List.repeat $n (let $e (cons $op (cons () ())) (reduce $e)))
       (let $t (mkNodeTemplate $op $cvs)
         (map evalRow $t (transposeCols $cvs)))))

;; --- Columnar node combine (child columns -> node column) --------------------
;; This is the columnar-kernel approach validated in experiments/memo-prototype
;; (the "dispatch evaluator"): instead of building a per-row template and
;; dispatching `reduce` once PER ROW (mkNodeTemplate/evalRow above), each
;; operator is ONE CLAUSE that folds the child COLUMNS with a whole-column
;; zipWith. On mux6 this was ~1.8x faster than the per-row sealed/reduce path
;; over the same &subtreeCache, with byte-identical output. Runs on PeTTaV1
;; (no lib_memo needed -- the &subtreeCache walk below is unchanged); dropping
;; in lib_memo per-subtree memoization is the further speedup that lands once
;; PR-165 is merged.
;;
;; Clause dispatch on the op (disjoint literal heads AND/OR/NOT, no variable
;; catch-all -> no overlapping-clause hazard), mirroring the prototype's
;; dispatchZip. Adding an operator is one clause here -- no evalSubtree change.
;; NOTE: the per-row template above (mkNodeTemplate/evalRow/transposeCols/
;; combineNode) is now LEGACY -- retained only because scoring/test/
;; boolean-ops-test.metta pins its internals; a real integration would migrate
;; that test and delete them.
(= (and2 $a $b) (if (and (== $a True) (== $b True)) True False))
(= (or2  $a $b) (if (or  (== $a True) (== $b True)) True False))
(= (colZipAnd $childCol $acc) (List.zipWith and2 $childCol $acc))
(= (colZipOr  $childCol $acc) (List.zipWith or2  $childCol $acc))
(= (colNot $col) (map-atom $col $b (if (== $b True) False True)))

;; combineOp: op x list-of-child-columns x row count -> node column. Folding an
;; empty child-column list over the identity seed reproduces the degenerate
;; arities: (AND ()) -> all-True, (OR ()) -> all-False (matches production).
(= (combineOp AND $childCols $n) (List.foldl colZipAnd (List.repeat $n True)  $childCols))
(= (combineOp OR  $childCols $n) (List.foldl colZipOr  (List.repeat $n False) $childCols))
(= (combineOp NOT $childCols $n) (colNot (car-atom $childCols)))

;; === FULL ZIPFORM PIPELINE (PR-165 lib_memo) -- EXPERIMENTAL ================
;; The boss-literal design: a REWRITE PASS materializes each candidate as an
;; explicit higher-order column term --
;;   (AND (x (OR (y z)))) -> (zZip and2 (zCol x) (zZip or2 (zCol y) (zCol z)))
;; -- then a dispatch evaluator scores it columnar-ly, with lib_memo memoizing
;; EACH sub-term so a sub-formula shared across candidates computes its column
;; ONCE (cross-candidate sub-term sharing -- the point of the boss's design).
;;
;; ROW FUNCTIONS are the and2/or2/not2 HELPERS (defined above / just below),
;; NOT the production AND/OR/NOT operators. rowFnOf maps a candidate op symbol
;; to its helper. This deliberately does NOT redefine production's AND/OR/NOT
;; (leaving reduct/crossover/representation untouched) -- an earlier attempt
;; that redefined them at binary arity broke the full solve even though the
;; scoring destructure worked in isolation.
;;  - Candidates from preOrderExp are quote-protected, so (AND (children))
;;    stays inert and the rewriter destructures it structurally (variable head).
;;  - The ops TABLES (monoids/memptyTable) are quote-protected because AND/OR
;;    ARE production-defined heads.
;;  - Dispatch tags are z-prefixed (zCol/zFmap/zZip/zZipN) because production
;;    defines a bare `zipWith` (utilities/general-helpers.metta:301).
;;
;; PR-165 ONLY (lib_memo). On PeTTaV1 the memoize calls no-op -> UNMEMOIZED
;; (correct but uncached). EXPERIMENTAL, local branch only, do NOT push.
!(import! &self (library lib_memo))
!(clear-memoize)
!(clear-memoize-stats)
!(config-memoize (unique-limit 100000) (strategy wtinylfu) (size-limit 5))
!(bind! &emCtx (new-space))
(= (emPut $rel $val)
   (let* (($_  (collapse (match &emCtx ($rel $o) (remove-atom &emCtx ($rel $o)))))
          ($_2 (add-atom &emCtx ($rel $val))))
     ()))
(= (emCtxTable) (car-atom (collapse (match &emCtx (emT $t) $t))))
(= (emCtxN)     (car-atom (collapse (match &emCtx (emN $n) $n))))

;; row-fn helpers: and2/or2 already defined above (for the retired combineOp);
;; not2 is the per-cell negation. These are NOT the production AND/OR/NOT ops.
(= (not2 $a) (if (== $a True) False True))
;; rowFnOf: candidate op symbol -> row-function helper. Single if-chain (no
;; overlapping clauses); unknown ops pass through unchanged.
(= (rowFnOf $op) (if (== $op AND) and2 (if (== $op OR) or2 (if (== $op NOT) not2 $op))))

;; monoid tables (quote-protected: AND/OR are production-defined heads). AND/OR
;; are associative with identities True/False -> n-ary folds to nested binary.
(= (monoids) (quote (AND OR)))
(= (isMonoid $op) (once (is-member $op (monoids))))
(= (memptyTable) (quote ((AND True) (OR False))))
(= (memptyScan () $op) (Error $op "mempty: no nullary identity"))
(= (memptyScan (cons ($k $v) $rest) $op) (if (== $k $op) $v (memptyScan $rest $op)))
(= (mempty $op) (memptyScan (memptyTable) $op))

;; --- rewriter: wrapped candidate -> materialized column term ----------------
(= (foldr1 $fn $children)
   (if (== (List.length $children) 1)
       (car-atom $children)
       (let $rest (foldr1 $fn (cdr-atom $children))
         (cons zZip (cons $fn (cons (car-atom $children) (cons $rest ())))))))
(= (rewriteTree $exp)
   (if (== (get-metatype $exp) Grounded)
       $exp
       (if (== (get-metatype $exp) Symbol)
           (cons zCol (cons $exp ()))
           (let ($op $children) $exp
             (case (List.length $children)
               ((0 (if (isMonoid $op) (mempty $op)
                       (Error $exp "rewriteTree: nullary non-foldable op")))
                (1 (let $c1 (rewriteTree (car-atom $children))
                     (if (isMonoid $op) $c1
                         (cons zFmap (cons (rowFnOf $op) (cons $c1 ()))))))
                (2 (let* (($l (rewriteTree (index-atom $children 0)))
                          ($r (rewriteTree (index-atom $children 1))))
                     (cons zZip (cons (rowFnOf $op) (cons $l (cons $r ()))))))
                ($_ (let $recChildren (map-atom $children $c (rewriteTree $c))
                      (if (isMonoid $op)
                          (foldr1 (rowFnOf $op) $recChildren)
                          (cons zZipN (cons (rowFnOf $op) (cons $recChildren ()))))))))))))
;; memoized rewrite (table-independent: same candidate -> same term)
!(memoize rewriteTreeCached 1)
(= (rewriteTreeCached $exp) (rewriteTree $exp))

;; --- evaluator: dispatch on the materialized term, memoized per sub-term ----
;; z-tags are structurally disjoint literal heads (no variable catch-all).
(= (dispatchZip (zCol $label))   (varColumn (emCtxTable) $label))
(= (dispatchZip (zFmap $f $c))   (map-atom (evalZipTerm $c) $v ($f $v)))
(= (dispatchZip (zZip $f $a $b)) (List.zipWith $f (evalZipTerm $a) (evalZipTerm $b)))
(= (dispatchZip (zZipN $op $cols))
   (map-atom (transposeCols (map-atom $cols $c (evalZipTerm $c))) $row ($op $row)))

!(memoize evalZipTerm 1)
(= (evalZipTerm $term)
   (if (== (get-metatype $term) Grounded)
       (List.repeat (emCtxN) $term)
       (dispatchZip $term)))

;; evalSubtree: publish table/n, then rewrite -> evaluate (both memoized).
;(: evalSubtree (-> Expression (ITable $a) Number (List Bool)))
(= (evalSubtree $exp $itable $n)
   (let* (($_  (emPut emT $itable))
          ($_2 (emPut emN $n)))
     (evalZipTerm (rewriteTreeCached $exp))))


 ;; Evaluates the accuracy of the expression for a single input row (target, inputs) pair.
 ;; This function determines whether the given boolean expression produces the expected result.
 ;;
 ;; Parameters:
 ;; - $expr: The boolean expression to evaluate.
 ;; - $row: A pair consisting of:
 ;;    - $target: The expected output.
 ;;    - $inputs: A set of truth assignments for variables.
 ;;
 ;; approach:
 ;;     - Extract $target (expected output) and $inputs (variable assignments).
 ;;     - Add the $inputs to the space using `add-reduct`.
 ;;     - Replace variables in $expr with their truth values from the space.
 ;;     - Evaluate the substituted expression.
 ;;     - Remove the added $inputs from the space to restore the original state.
 ;;     - If the evaluated result matches the $target, return 1 (correct); otherwise, return 0

(= (rowFitness $expr $row )
    (let*
      (
        ($target (car-atom $row))
        ($inputs (cdr-atom $row))
        ($add (map-atom $inputs $z (add-atom &space $z)))
        ($replacedExpr (let $acc (replaceWithTruth $expr &space (collapse (match &space $x $x))) (if (== (get-metatype $acc) Symbol) ($acc) $acc))) ;; This is a guard added to prevent a symbol being returned here which will cause the rest of the logic to fail. It is an edge case that happens if none of the variables are defined or the first variable explored is an undefined variable.
        ($isFaulty  (findX $replacedExpr undefined))  ;; Check if there are any undefined variables in the expression
        ($evaluateuatedResult  (if (not $isFaulty) (evaluate $replacedExpr) null )) ;; No need to evaluate if there are undefined variables in the experession
        ($remove (map-atom $inputs $z (remove-atom &space $z)))
      )
      (if (== $evaluateuatedResult $target) 1 0)
      )
)


 ;; Measure the accuracy of the expression based on the given dataset.
 ;; The function evaluates how well the boolean expression matches the given truth table.
 ;;
 ;; Args:
 ;;     - $expr: The boolean expression to be evaluated.
 ;;     - $data: A dataset containing multiple rows of input-output mappings.

(= (fitness $expr $data)
    (if (== $data ())
        0
        (let $result (map-atom $data $d (rowFitness $expr $d)) (sum $result))
    )
)

;  ;; Computes the penalized fitness of an expression by balancing accuracy and complexity.
;  ;; The penalty factor $lambda(just like learning rate) controls the trade-off between correctness and simplicity.

(= (penalizedFitness $expr $data $lambda)
    (let*
      (
        ($accuracy (fitness $expr $data))
        ($complexity (counter $expr))
      )
        (- $accuracy (* $lambda $complexity))
    )
)



;; helper function to calculate the how many AND and OR operators are in the expression

(= (counter $expr)
    (if (or (== $expr ()) (== (get-metatype $expr) Symbol))
        0
        (let*
          (
            ($head  (car-atom $expr))
            ($tail (cdr-atom $expr))
          )
          (if (== (get-metatype $head) Expression)
              (+ (counter $head) (counter $tail))
              (if (or (== $head AND) (== $head OR))
                  (+ 1 (counter $tail))
                  (counter $tail)
              )
          )
        )
    )
)
