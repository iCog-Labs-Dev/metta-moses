
! (bind! &space (new-space))

(= (removeFromSpace $row $space) (remove-atom $space $row))

;  This function counts the total occurrences of variable $X in an expression non-deterministically.
(= (findX $expr $x)
    (if (== $expr ())
        (empty)
        (let $a (superpose $expr)
            (if (or (== (get-metatype $a) Grounded) (== (get-metatype $a) Symbol))
                (if (== $a $x)
                    1
                    (empty)
                )
                (findX $a $x)
            )
        )
    )
)

 ;; Replaces variables in an expression with their corresponding truth values from the space.
 ;; If a variable is not found, it is replaced with undefined.
(= (replaceWithTruth $expr $space $spaceContent)
    (if (== (get-metatype $expr) Expression) 
        (if (== (cdr-atom $expr) ()) ;; Special case: (A) → Should replace as a symbol
            (collapse (replaceWithTruth (superpose $expr) $space $spaceContent))
            (let* (
                ($op (car-atom $expr))
                ($tuple (cdr-atom $expr)) 
                ($substitutedArgs (collapse (replaceWithTruth (superpose $tuple) $space $spaceContent)) )
                ($tupleWithOp (cons-atom $op $substitutedArgs))
            )
                $tupleWithOp
            )
        )
        ((unify $space ($expr $value) $value undefined)) ;; If not an Expression, replace normally
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
        ($add (collapse (add-reduct &space (superpose $inputs) )))
        ($replacedExpr (replaceWithTruth $expr &space (collapse (match &space $x $x))))
        ($isFaulty  (collapse (findX $replacedExpr undefined)))  ;; Check if there are any undefined variables in the expression
        ($evaluateuatedResult  (if (== $isFaulty ()) (evaluate $replacedExpr) null )) ;; No need to evaluate if there are undefined variables in the experession
        ($remove (collapse (removeFromSpace (superpose $inputs) &space)))
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
        (let $result (collapse (rowFitness $expr (superpose $data))) (sum $result)) 
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
