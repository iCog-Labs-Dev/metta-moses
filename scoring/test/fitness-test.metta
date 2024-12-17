! (register-module! ../../../metta-moses)
! (import! &self metta-moses:scoring:fitness)


; ; ; Test Cases 1: Simple AND Expression
; ; !(penalizedFitness (AND A (OR B C)) 
; ;                    ((True (A True) (B True) (C False)) 
; ;                     (False (A False) (B True) (C True))) 
; ;                    0.1) ; Expected: 1.8

; ; ; Test Case 2: Nested OR Expression
; ; !(penalizedFitness (OR (AND A B) C) 
; ;                    ((True (A True) (B False) (C True)) 
; ;                     (True (A True) (B True) (C False)) 
; ;                     (False (A False) (B False) (C False))) 
; ;                    0.1) ; Expected: 2.8

; ; ; Test Case 3: Complex Expression
; ; !(penalizedFitness (OR (AND A (NOT B)) (AND C D)) 
; ;                    ((True (A True) (B False) (C True) (D True)) 
; ;                     (False (A False) (B True) (C False) (D False)) 
; ;                     (True (A True) (B False) (C False) (D True))) 
; ;                    0.1) ; Expected: 2.7



