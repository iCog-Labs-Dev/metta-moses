! (register-module! ../../EDA)
! (import! &self EDA:scoring:general-helpers)
! (bind! &space (new-space))
;! (import! &test testData)


; measure the accuracy of the exprssion based on the given data 
(= (fitness $expr $data)
    (if (== $data ())
        0
        (let*(
            ($result (collapse (rowFitness $expr (superpose $data)))))

            (foldr + 0 $result)
        )
    )
)

; evaluate the fitness of a single row 
(= (rowFitness $expr $row )
    (let* (
            ($target (car-atom $row))
            ($inputs (cdr-atom $row))
            ($add (collapse (addToSpace (superpose $inputs) &space)))
            ($replacedExpr (replaceWithTruth $expr &space (collapse (match &space $x $x))))
            ($evaluateuatedResult (evaluate $replacedExpr))
            ($remove (collapse (removeFromSpace (superpose $inputs) &space)))
        )
        (if (== $evaluateuatedResult $target) 1 0)
    )
)



(= (penalizedFitness $expr $data $lambda)
    (let* (
        ($accuracy (fitness $expr $data)) 
        ($complexity (counter $expr))    
    )
        (- $accuracy (* $lambda $complexity))  
    )
)

;; Test Cases 1: Simple AND Expression
; !(penalizedFitness (AND A (OR B C)) 
;                    ((True (A True) (B True) (C False)) 
;                     (False (A False) (B True) (C True))) 
;                    0.1)

; ; Test Case 2: Nested Expression
; !(penalizedFitness (OR (AND A B) C) 
;                    ((True (A True) (B False) (C True)) 
;                     (True (A True) (B True) (C False)) 
;                     (False (A False) (B False) (C False))) 
;                    0.1) ; Expected: 2.8

; ; Test Case 3: Complex Expression
; !(penalizedFitness (OR (AND A (NOT B)) (AND C D)) 
;                    ((True (A True) (B False) (C True) (D True)) 
;                     (False (A False) (B True) (C False) (D False)) 
;                     (True (A True) (B False) (C False) (D True))) 
;                    0.1) ; Expected: 2.7



; !(fitness (OR (AND A (NOT B)) (AND C D))
;             ((True (A True) (B False) (C True) (D True)) 
;             (False (A False) (B True) (C False) (D False)) 
;             (True (A True) (B False) (C False) (D True))) )


; !(fitness (AND A (OR B C)) ( (True (A True) (B True) (C True)) (True (A False) (B False) (C True)) ) )

;;!(fitness (AND A (OR B C)) ( (True (A True) (B True) (C True)) (True (A False) (B False) (C True)) (False (A False) (B False) (C False)) ) )
;;!(fitness (AND A (OR B C)) ( (False (A False) (B True) (C True)) (False (A True) (B False) (C True)) ) )








