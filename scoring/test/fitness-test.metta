! (register-module! ../../../metta-moses)

! (import! &self metta-moses:scoring:fitness)
! (import! &self metta-moses:utilities:general-helpers)


;; Test Cases 1: Simple AND Expression
!(assertEqual
   (penalizedFitness
     (AND A (OR B C))
      ((True (A True) (B True) (C False)) 
       (False (A False) (B True) (C True)))
     0.1)
   1.8)

;; Test Case 2: Nested OR Expression
!(assertEqual 
   (penalizedFitness 
     (OR (AND A B) C)
     ((True (A True) (B False) (C True))
      (True (A True) (B True) (C False))
      (False (A False) (B False) (C False)))
     0.1)
   2.8)

;; Test Case 3: Complex Expression
!(assertEqual 
   (penalizedFitness 
     (OR (AND A (NOT B)) (AND C D))
     ((True (A True) (B False) (C True) (D True))
      (False (A False) (B True) (C False) (D False))
      (True (A True) (B False) (C False) (D True)))
     0.1)
   2.7)

;; Test case 4: AND Expression
!(assertEqual
  (penalizedFitness
      (AND A B)
      ((True (A True) (B True))
       (False (A False) (B True))
       (False (A True) (B False))
       (False (A False) (B False)))
      0.0)
  4.0
)
 
;; Test case 5: OR Expression
!(assertEqual
  (penalizedFitness
      (OR A B)
      ((True (A True) (B True))
       (False (A False) (B True))
       (False (A True) (B False))
       (False (A False) (B False)))
      0.0)
  2.0)


;; Test Case 6: Nested OR Expression with undefined variable
!(assertEqual 
   (penalizedFitness 
     (OR (AND X B) C)
     ((True (A True) (B False) (C True))
      (True (A True) (B True) (C False))
      (False (A False) (B False) (C False)))
     0.1)
   -0.2)

;; Test Case 7: Complex Expression with undefined variable
!(assertEqual 
   (penalizedFitness 
     (OR (AND P (NOT Q)) (AND R S) (AND T U))
     ((True (A True) (B False) (C True) (D True))
      (False (A False) (B True) (C False) (D False))
      (True (A True) (B False) (C False) (D True)))
     0.1)
   -0.4)

;; Test Case 8: Simple Expression with no connective - Symbol
!(assertEqual 
   (penalizedFitness 
     (A)
     ((True (A True))
      (False (A False)))
     0.1)
   2)

;; Test Case 9:
!(assertEqual 
   (penalizedFitness 
     (A)
     ((False (A True))
      (False (A False)))
     0.1)
   1)

;; Test Case 10: simple expression but complex data
!(assertEqual 
   (penalizedFitness 
     (A)
    ((True (A True) (B False) (C True) (D True))
      (False (A False) (B True) (C False) (D False))
      (True (A True) (B False) (C False) (D True)))
     0.1)
   3)

;; Test Case 11: Simple Expression with negation
!(assertEqual 
   (penalizedFitness 
     (NOT A)
     ((False (A True))
      (True (A False)))
     0.1)
   2)

;; Test Case 12: Symbol
!(assertEqual 
   (penalizedFitness 
     A
     ((True (A True)))
     0.1)
   1)

;; Test Case 13: Symbol undefined
!(assertEqual 
   (penalizedFitness 
     A
     ((True (P True)))
     0.1)
   0)
