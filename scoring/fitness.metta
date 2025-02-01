! (bind! &space (new-space))


(= (removeFromSpace $row $space) (remove-atom $space $row))

;; Replace expersion with Truth value from the space.
(= (replaceWithTruth $expr $space $spaceContent)
    (if (== (get-metatype $expr) Expression) 
        (let* (
            ($op (car-atom $expr))
            ($tuple (cdr-atom $expr)) 
            ($substitutedArgs (collapse (replaceWithTruth (superpose $tuple) $space $spaceContent)) )

            ($tupleWithOp (cons-atom $op $substitutedArgs))
        )
            $tupleWithOp
        )
         (unify $space ($expr $value) $value 'undefined') 
    )
)

;; A function to evaluateuate the boolean expression
(= (evaluate $expr)
    (if (== (get-metatype $expr) Grounded) ;; T/ F
        $expr
        (let* 
          (
            ($op (car-atom $expr))
            ($tuple (cdr-atom $expr))
          )
          (case $op 
            (
              (AND (evaluateAnd $tuple))
              (OR (evaluateOr $tuple))
              (NOT (not (evaluate $tuple)))
              ($_ ERROR)

            )
          )
        )
    )
)

;; Evaluate OR subexpression
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

;; Evaluate AND subexpression
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


;; Count the total AND & OR operators in the expression.
(= (counter $expr)
    (if (== $expr ())
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

;; Measure the accuracy of the exprssion based on the given data 
(= (fitness $expr $data)
    (if (== $data ())
        0
        (let*
          (
            ($result (collapse (rowFitness $expr (superpose $data))))
          )
          (sum $result)
        )
    )
)

;; Evaluates the accuracy of the expression based on the single input row => (target, inputs) pare.
(= (rowFitness $expr $row )
    (let*
      (
        ($target (car-atom $row))
        ($inputs (cdr-atom $row))
        ($add (collapse (add-reduct &space (superpose $inputs) )))
        ($replacedExpr (replaceWithTruth $expr &space (collapse (match &space $x $x))))
        ($evaluateuatedResult (evaluate $replacedExpr))
        ($remove (collapse (removeFromSpace (superpose $inputs) &space)))
      )
      (if (== $evaluateuatedResult $target) 1 0)
    )
)



(= (penalizedFitness $expr $data $lambda)
    (let*
      (
        ($accuracy (fitness $expr $data))
        ($complexity (counter $expr))
      )
        (- $accuracy (* $lambda $complexity))
    )
)





