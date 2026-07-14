
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
;; Columnar (vectorized) subtree evaluation with memoization.
;;
;; Instead of substituting variables per row and re-evaluating the whole tree,
;; each subtree is evaluated ONCE into a boolean vector over all table rows and
;; memoized in &subtreeCache, keyed by its canonical (preOrder) expression.
;; Common subtrees (e.g. (AND A B)) recur across candidates, so the hit rate is
;; far higher than the whole-tree cache and shared work is done only once.
;; ---------------------------------------------------------------------------

;; Extract a variable's column (one boolean per row) from the input table.
;(: varColumn (-> (ITable $a) Symbol (List Bool)))
(= (varColumn (mkITable $rows $labels) $label)
   (let $idx (List.index $labels $label)
        (if (== $idx -1)
            ;; Leaf references a label not in the table. Real candidate trees are
            ;; built from the table's features so this is a malformed input; fail
            ;; loudly rather than silently scoring every row -1 (List.getByIdx -1).
            (Error $label "varColumn: label not found in table")
            ;; $idx is already validated (>= 0, and rows are as wide as $labels),
            ;; so index straight into the row with the grounded index-atom builtin
            ;; instead of List.getByIdx, which re-scans the row (size-atom) for a
            ;; redundant bounds check on every cell.
            (map-atom $rows $r (index-atom $r $idx)))))

;; Reduce a list of equal-length boolean columns elementwise with a binary op,
;; starting from $acc. Generalizes n-ary AND/OR: pass `and` or `or`.
(= (reduceColumns $op $acc $cols)
   (if (== $cols ())
       $acc
       (reduceColumns $op (List.zipWith $op $acc (car-atom $cols)) (cdr-atom $cols))))

;; Combine child columns for an operator node. AND/OR reduce from the first child
;; (empty $vs falls back to the identity column, covering preOrder's unit-filtered
;; empty AND/OR); NOT negates its child inline (too simple to warrant a helper).
;; A single case-dispatch (not separate clauses) avoids non-deterministic overlap.
;; Any other head (e.g. an unreduced (reduce-to ...) wrapper left on a degenerate
;; tree) mirrors the old evaluator, which returned ERROR -> scores worst (-1).
;(: combineSubtrees (-> Symbol (List (List Bool)) Number (List Bool)))
(= (combineSubtrees $op $vs $n)
   (case $op
     ((AND (if (== $vs ()) (List.repeat $n True)  (reduceColumns and (car-atom $vs) (cdr-atom $vs))))
      (OR  (if (== $vs ()) (List.repeat $n False) (reduceColumns or  (car-atom $vs) (cdr-atom $vs))))
      (NOT (List.map not (car-atom $vs)))
      ($_  (List.repeat $n ERROR)))))

;; Evaluate a canonical (preOrder) (sub)expression into a boolean vector over
;; all rows, memoizing operator nodes in &subtreeCache. $n is the number of rows.
;(: evalSubtree (-> Expression (ITable $a) Number (List Bool)))
(= (evalSubtree $expr $itable $n)
   (if (== (get-metatype $expr) Expression)
       (if (== (cdr-atom $expr) ())
           ;; single element: (AND)/(OR) identity, or (X) unwrap
           (let $h (car-atom $expr)
             (case $h
               ((AND (List.repeat $n True))
                (OR  (List.repeat $n False))
                ($_  (evalSubtree $h $itable $n)))))
           ;; operator node: lookup, else recurse children, combine, cache
           (chain (collapse (match &subtreeCache (subtree $expr $v) $v)) $hit
             (if (== $hit ())
                 (let* ((($op $args)   (decons-atom $expr))
                        ($cvs  (map-atom $args $a (evalSubtree $a $itable $n)))
                        ($vec  (combineSubtrees $op $cvs $n))
                        ($_    (add-atom &subtreeCache (subtree $expr $vec))))
                   $vec)
                 (car-atom $hit))))
       ;; atom leaf: grounded literal (True/False) vs variable column
       (if (== (get-metatype $expr) Grounded)
           (List.repeat $n $expr)
           (varColumn $itable $expr))))


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
