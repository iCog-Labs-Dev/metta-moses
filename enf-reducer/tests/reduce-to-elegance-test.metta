! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate-truth-value)
! (import! &self metta-moses-reduction:enf-reducer:reduce-to-elegance)

! (import! &self metta-moses-reduction:enf-reducer:post-processing)
! (import! &self metta-moses-reduction:enf-reducer:reduct)
! (import! &self metta-moses-reduction:enf-reducer:gather-junctors)

! (import! &self metta-moses-reduction:enf-reducer:tests:test-treenodes)

;; Test for applyAndCut function

;; Test 01 - Node with one child and empty guardSet
!(assertEqual 
   (applyAndCut 
     (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value b True LITERAL) Nil Nil) Nil) ) )
     (TreeNode (Value K True AND) Nil (Cons (TreeNode ( Value J True OR) Nil (Cons (TreeNode ( Value I True LITERAL) (Cons (TreeNode ( Value G False LITERAL) Nil Nil) Nil) (Cons (TreeNode ( Value H True OR) Nil Nil) Nil) ) Nil) ) Nil) )
   ) 
   ((TreeNode (Value K True AND) Nil (Cons (TreeNode (Value J True OR) Nil (Cons (TreeNode (Value I True LITERAL) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value H True OR) Nil Nil) Nil)) Nil)) Nil)) False)
 )


;; Test for applyorcut function

;; Test 01
!(assertEqual 
   (applyOrCut 
     (TreeNode (Value B False OR) Nil (Cons (TreeNode (Value C False LITERAL) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil) ) (Cons (TreeNode (Value D True LITERAL) Nil Nil) Nil) ) Nil) )
     (TreeNode (Value A True AND) (Cons (TreeNode (Value G0 True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value E False LITERAL) Nil Nil) Nil )) 
   )
   (TreeNode (Value A True AND) (Cons (TreeNode (Value G0 True LITERAL) Nil Nil) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value D True LITERAL) Nil Nil) Nil)))
 )


;; Test for commandSetIterator function

;; Test 02
!(assertEqual 
    (commandSetIterator 
      (TreeNode (Value D True AND) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) Nil)  Nil)
      (Cons (TreeNode (Value D True AND) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) Nil)  Nil) (Cons (TreeNode (Value E True AND) (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil)  Nil) (Cons (TreeNode (Value F True OR) Nil  (Cons (TreeNode (Value D True AND) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) Nil)  Nil) (Cons (TreeNode (Value E True AND) (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil)  Nil) Nil))) Nil)))
      Nil
    )
    (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil)
 )

;; Test 03
! (assertEqual (commandSetIterator NilNode Nil Nil) Nil)


;; Test for intersections function

;; Test 01
!(assertEqual (intersections Nil) Nil)

;; Test 02
!(assertEqual
   (intersections
     (Cons (TreeNode ( Value AND True AND) (Cons (TreeNode ( Value A True LITERAL) Nil Nil) (Cons (TreeNode ( Value B True LITERAL) Nil Nil) Nil)) Nil) Nil)
   )
   (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil))
 )


;; Test for containsTerminalAndNode function

;; Test 01
!(assertEqual 
   (containsTerminalAndNode 
     (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil)
   )
   False
 )

;; Test 02
!(assertEqual 
   (containsTerminalAndNode 
     (Cons (TreeNode (Value "D" False OR) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil) Nil) Nil)
   )
   False
 )

;; Test 03
!(assertEqual
   (containsTerminalAndNode 
     (Cons (TreeNode (Value "C" False AND) Nil (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value "B" False AND) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value "D" False OR) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil) Nil) Nil)))
   )
   True
 )

;; Test 04
!(assertEqual
   (containsTerminalAndNode 
     (Cons (TreeNode (Value "C" False AND) Nil (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value "D" False OR) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value "E" False AND) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" False AND) Nil (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil)) Nil)) Nil) Nil)))
   )
   False
 )

;; Test case for compareSets function

;; Test 01
!(assertEqual 
   (compareSets 
     (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode (Value "B" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) Nil)))
     (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode (Value "B" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) Nil)))
   )
   True
 )

;; Test 02
!(assertEqual 
   (compareSets 
     (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode  (Value "B" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) Nil)))
     (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode (Value "K" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) Nil)))
   )
   False
 )


;; Test case for orSubTreeElegance function

;; Test 01
!(assertEqual 
  (orSubTreeElegance 
     (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) 
     (TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil))) 
     (Cons (TreeNode (Value G7 False LITERAL) Nil Nil) Nil)
      (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
   )
   ((TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) Nil Nil) Nil))) DISCONNECT)
 )

;; Test case for andSubTreeElegance function

;; Test 01
!(assertEqual
   (andSubTreeElegance
     (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil)
     (TreeNode (Value S True AND) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil)))
     (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
     (Cons (TreeNode (Value G7 False LITERAL) Nil Nil) Nil)
   )
   ((TreeNode (Value S True AND) Nil (Cons (TreeNode (Value P True AND) Nil Nil) Nil)) ADVANCE)
 )


;; Test case for iterator function

;; Test 01
!(assertEqual
   (iterator 
     (TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil))) 
     (Cons (TreeNode (Value G5 False LITERAL) Nil Nil) Nil)
     (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
   )
   ((TreeNode (Value R True OR) Nil Nil) NONE)
 )



;; Test case for orSubTreeIterator function

;; Test 01
!(assertEqual
  (orSubTreeIterator 
    (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil) 
    (TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil)))
    (Cons (TreeNode (Value G5 False LITERAL) Nil Nil) Nil)
    (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
    0
  )
  ;; ((TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil))) DISCONNECT)
 ((TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) Nil Nil) Nil))) DISCONNECT)
)


;; Test case for andSubTreeIterator

;; Test 01
!(assertEqual
  (andSubTreeIterator 
    (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil)) 
    (TreeNode (Value S True AND) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil)))
    (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
    (Cons (TreeNode (Value G7 False LITERAL) Nil Nil) Nil)
    0
  )
  ((TreeNode (Value S True AND) Nil Nil) NONE)
 )

;; Test for isTreeWellFormed

;; Test 01
!(assertEqual
   (isTreeWellFormed (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value a False LITERAL) Nil Nil) (Cons (TreeNode (Value b False LITERAL) Nil Nil) Nil))))
   True 
 )

;; Test case for reduceToElegance function

;; Test 01
!(assertEqual
  (reduceToElegance 
    (TreeNode (Value R True OR) (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)) Nil) 
    (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) 
    (Cons (TreeNode (Value G5 False LITERAL) Nil Nil) Nil)
    (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
  )
  ((TreeNode (Value R True OR) (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)) Nil) (TreeNode (Value Q True AND) Nil Nil) DISCONNECT)
 )

;; Test 02
!(assertEqual
  (reduceToElegance (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
  ;; ((TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) Nil) KEEP)
  ((TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) (TreeNode (Value Nil False AND) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) Nil) KEEP)
)

;; Test 03
!(assertEqual
  (reduceToElegance (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) Nil Nil)
  ((TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) (TreeNode (Value Nil False OR) (Cons (TreeNode (Value a True AND) Nil Nil) Nil) (Cons (TreeNode (Value b True AND) Nil Nil) Nil)) DISCONNECT)
 )


;; RTE Transformation test cases

;; Test 01: Delete inconsistent handle

;; input expression:  (AND A (OR (AND (NOT A) B C) B))
;; output expression: (AND A (OR B))

;; Test 04: Test case from Mosh's paper. Page 37
;;
;; !(reduceToElegance
;;     (TreeNode (And) Nil (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (g) Nil) Nil) (Cons (TreeNode (And) (Cons (a) (Cons (b) Nil)) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c') Nil) Nil) (Cons (TreeNode (And) (Cons (d') Nil) Nil) (Cons (TreeNode (And) (Cons (e) Nil) Nil) Nil)))) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c) Nil) Nil) (Cons (TreeNode (And) (Cons (c) (Cons (f) Nil)) Nil) Nil))) Nil))) Nil))) Nil))
;;     (TreeNode (And) Nil (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (g) Nil) Nil) (Cons (TreeNode (And) (Cons (a) (Cons (b) Nil)) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c') Nil) Nil) (Cons (TreeNode (And) (Cons (d') Nil) Nil) (Cons (TreeNode (And) (Cons (e) Nil) Nil) Nil)))) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c) Nil) Nil) (Cons (TreeNode (And) (Cons (c) (Cons (f) Nil)) Nil) Nil))) Nil))) Nil))) Nil))
;;       Nil
;;       Nil)
; (assertEqual
;    (reduceToElegance
;      (TreeNode (And) Nil (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (g) Nil) Nil) (Cons (TreeNode (And) (Cons (a) (Cons (b) Nil)) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c') Nil) Nil) (Cons (d') (Cons (e) Nil)))) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (c) Nil) (Cons (TreeNode (And) (Cons (c) (Cons (f) Nil)) Nil) Nil))) Nil))) Nil))) Nil))
;      (TreeNode (And) Nil (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (g) Nil) Nil) (Cons (TreeNode (And) (Cons (a) (Cons (b) Nil)) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (Cons (c') Nil) Nil) (Cons (d') (Cons (e) Nil)))) (Cons (TreeNode (Or) Nil (Cons (TreeNode (And) (c) Nil) (Cons (TreeNode (And) (Cons (c) (Cons (f) Nil)) Nil) Nil))) Nil))) Nil))) Nil))
;       Nil
;       Nil)
;  )
