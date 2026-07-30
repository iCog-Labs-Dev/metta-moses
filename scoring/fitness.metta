
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
;; Columnar subtree evaluation: every subtree is evaluated ONCE into a boolean
;; column over all rows of the run's single fixed table, never row-by-row
;; expression rewriting. Operator semantics live solely in the AND/OR/NOT
;; clauses (scoring/boolean-ops); a head with no clause stays unreduced and
;; scores worst (-1), like the old ERROR column. varColumn (immediately below)
;; is the table accessor; the live scoring path is the zipform column engine
;; further down (rewriteTree -> evalSubtree).
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

;; --- LEGACY per-row node evaluation -----------------------------------------
;; mkNodeTemplate / evalRow / combineNode build one wrapped node's column by
;; dispatching `reduce` ONCE PER ROW. On no scoring path; retained only because
;; scoring/test/boolean-ops-test.metta pins their internals. transposeCols is
;; NOT legacy -- zipWithN still uses it.
;;
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

;; === ZIPFORM COLUMN ENGINE (compile -> materialized term -> memoized walk) ==
;; rewriteTree compiles each candidate Tree into an explicit column term --
;;   (AND x (OR y z)) -> (zipWith AND (col x) (zipWith OR (col y) (col z)))
;; -- and evalSubtree walks that term bottom-up, memoizing PER SUB-TERM, so a
;; sub-formula shared across candidates computes its column ONCE.
;; ROW FUNCTIONS are the AND/OR/NOT/XOR operators at their row arity
;; (scoring/boolean-ops): the compiler passes the op SYMBOL straight into
;; (zipWith $op ..) / (fmap $op ..), so there is no rowFnTable.
;;
;; HAZARD -- col / fmap / zipWith / zipWithN and the operator symbols are all
;; LIVE HEADS, so every mention of them as DATA (every emitted term, and the op
;; tables below) must be `quote`d, or it fires instead of staying inert.
;;
;; lib_memo supplies the memoization; without it the memoize directives no-op
;; and the same code runs correct but uncached.
!(import! &self (library lib_memo))
!(clear-memoize)
!(clear-memoize-stats)
!(config-memoize (unique-limit 100000) (strategy wtinylfu) (size-limit 5))

;; --- table plumbing ---------------------------------------------------------
;; !! ENTRY-FILE REQUIREMENT: any entry file that imports scoring/fitness AND
;; scores must import parameters/registry FIRST -- otherwise setZipTable never
;; binds and evalTree yields ZERO solutions with no error, so every downstream
;; assertion passes vacuously.
;;
;; setZipTable: install the run's fixed table and cache its row count, which
;; `col` and the True/False broadcast read back. The destructuring binding must
;; stay inside the let*.
(= (setZipTable $itable)
   (let* (((mkITable $rows $labels) $itable)
          ($_  (set-param zipTable $itable))
          ($_2 (set-param zipRowCount (List.length $rows))))
     (List.length $rows)))

;; --- the zip term's vocabulary, as functions over evaluated child columns ----
;; zipWith is absent on purpose: general-helpers' zipWith already IS the
;; binary-row-function-over-two-columns combinator this term shape needs.
(= (col $label)         (varColumn (param zipTable) $label))
(= (fmap $f $c)         (map-atom $c $v ($f $v)))
(= (zipWithN $op $cols) (map-atom (transposeCols $cols) $row ($op $row)))

;; --- op tables --------------------------------------------------------------
;; A monoid op folds: n-ary nodes right-fold into nested BINARY zipWith terms,
;; 0 children -> the identity column, 1 child -> the child. NOT is unary and so
;; absent. ADDING A BOOLEAN OPERATOR costs, by kind:
;;   binary  -- one row clause (= (OP $a $b) ..) in scoring/boolean-ops.metta.
;;   unary   -- (= (OP $a) ..); reached via `fmap`, so it gets a BARE cell.
;;   n-ary   -- (= (OP ($a $b $c)) ..); reached via `zipWithN`, one row tuple.
;;   monoid  -- the row clause PLUS registration in (monoids) and (memptyTable)
;;              here, the only registration sites; rewriteTree derives the rest.
(= (monoids) (quote (AND OR XOR)))
(= (isMonoid $op) (once (is-member $op (monoids))))
(= (memptyTable) (quote ((AND True) (OR False) (XOR False))))
(= (memptyScan () $op) (Error $op "mempty: no nullary identity registered for this op"))
(= (memptyScan (cons ($k $v) $rest) $op)
   (if (== $k $op) $v (memptyScan $rest $op)))
;; mempty: op symbol -> its 0-arity identity. Loud Error default -- silently
;; guessing a wrong identity would corrupt every row of the column.
(= (mempty $op) (memptyScan (memptyTable) $op))

;; --- rewriter helper --------------------------------------------------------
;; foldr1: right-fold an already-rewritten (arity > 2) child-column list into
;; nested binary zipWith terms with row fn $fn (here the op symbol itself).
;; HAZARD: quoted emission (`zipWith` is live). `quote` only SUBSTITUTES bound
;; variables, so the head child is let-bound rather than inlined as (car-atom ..).
(= (foldr1 $fn $children)
   (if (== (List.length $children) 1)
       (car-atom $children)
       (let* (($hd   (car-atom $children))
              ($rest (foldr1 $fn (cdr-atom $children))))
         (quote (zipWith $fn $hd $rest)))))

;; --- rewriteTree: candidate Tree ADT -> materialized columnar term ----------
;; CONSUMES the mkTree / mkNode / mkKnob candidate ADT and EMITS the columnar
;; term as inert DATA (every emission quoted -- see the HAZARD above): this is a
;; COMPILER, not an evaluator, and never reads the table or computes a column.
;; An n-ary monoid node right-folds (foldr1) into NESTED BINARY terms rather
;; than one flat node, so each nesting level is its own memo key -- that is
;; where the cross-candidate sub-column sharing comes from. Both nullary paths
;; guard on isMonoid (the childless clause here, the zero-SURVIVING-children
;; case in the operator clause), so they agree for every registered monoid.
;; Only the ROOT call is memoized; the recursion is not.
;;
;; Childless node: a monoid gives its identity, True/False pass straight
;; through, anything else is a leaf label and compiles to its column reference.
(= (rewriteTree (mkTree (mkNode $r) ()))
   (if (isMonoid $r)
       (mempty $r)
       (if (or (== $r True) (== $r False))
           $r
           (quote (col $r)))))

;; Knob clauses, reachable because this compiler consumes the raw ADT: a null
;; knob contributes nothing (the operator clause's filter drops it), a real knob
;; compiles its inner tree with $lsk and $i discarded.
(= (rewriteTree (mkKnob (mkNullVex $tree) $lsk $i)) ())
(= (rewriteTree (mkKnob (mkTree $node $children) $lsk $i))
   (rewriteTree (mkTree $node $children)))

;; Operator node. Children are compiled in place and null-knob children drop
;; out, so it is the SURVIVING count -- not the declared one -- that drives the
;; dispatch, and 0 IS reachable (every child a null knob); the $_ branch must
;; not swallow it, hence the explicit 0 case. All emissions are quoted, the
;; 0-case Error argument included: it reports the offending node as data.
(= (rewriteTree (mkTree (mkNode $r) (cons $x $xs)))
   (let $cols (filter-atom (map-atom (cons $x $xs) $c (rewriteTree $c)) $y (!= $y ()))
     (case (List.length $cols)
       ((0 (if (isMonoid $r)
               (mempty $r)
               (Error (quote ($r ())) "rewriteTree: nullary non-foldable op")))
        (1 (let $c1 (car-atom $cols)
             (if (isMonoid $r)
                 $c1
                 (quote (fmap $r $c1)))))
        (2 (let* (($lc (index-atom $cols 0))
                  ($rc (index-atom $cols 1)))
             (quote (zipWith $r $lc $rc))))
        ($_ (if (isMonoid $r)
                (foldr1 $r $cols)
                (quote (zipWithN $r $cols))))))))

;; Memoized compile. TABLE-INDEPENDENT: the same candidate always compiles to
;; the same term whatever table is installed, so this cache never needs clearing
;; for correctness. Keyed on the RAW ADT, which carries knob identity ($lsk/$i).
!(memoize rewriteTreeCached 1)
(= (rewriteTreeCached $tree) (rewriteTree $tree))

;; --- evaluator: one generic memoized walk over the materialized term --------
;; True/False broadcast to a full column; an Expression evaluates its children
;; first (each through the memo) and `reduce`s the rebuilt node, firing
;; col/fmap/zipWith/zipWithN; anything else (an op symbol riding as a
;; row-function argument) passes through.
!(memoize evalSubtree 1)
(= (evalSubtree $term)
   (if (or (== $term True) (== $term False))
       (List.repeat (param zipRowCount) $term)
       (if (== (get-metatype $term) Expression)
           (let $node (map-atom $term $c (evalSubtree $c))
             (reduce $node))
           $term)))

;; evalTree/3: the scoring entry point -- publish the table, then compile ->
;; walk (both memoized). evalTree takes a candidate TREE, evalSubtree an
;; already-materialized columnar TERM. $n is unused -- the row count comes from
;; setZipTable -- but the arity is kept because callers pass it.
;(: evalTree (-> (Tree $a) (ITable $a) Number (List Bool)))
(= (evalTree $tree $itable $n)
   (let $_ (setZipTable $itable) (evalSubtree (rewriteTreeCached $tree))))


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
