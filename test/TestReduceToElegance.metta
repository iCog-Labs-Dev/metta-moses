! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types) 
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:utilities:generalHelperFunctions)
! (import! &self metta-moses-reduction:enf-reducer:RTEHelpers)
! (import! &self metta-moses-reduction:enf-reducer:propagate_truth_value)
! (import! &self metta-moses-reduction:enf-reducer:reduce_to_elegance)

! (import! &self metta-moses-reduction:enf-reducer:postProcessing)
! (import! &self metta-moses-reduction:enf-reducer:reduct)
! (import! &self metta-moses-reduction:enf-reducer:gather-junctors)

;; Test for applyAndCut function

;; Test 01 - Node with one child and empty guardSet
;; ! (assertEqual (applyAndCut (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value a True LITERAL) Nil Nil) (Cons (TreeNode (Value b True LITERAL) Nil Nil) Nil) ) ) (TreeNode (Value K True AND) Nil (Cons (TreeNode ( Value J True OR) Nil (Cons (TreeNode ( Value I True LITERAL) (Cons (TreeNode ( Value G False LITERAL) Nil Nil) Nil) (Cons (TreeNode ( Value H True OR) Nil Nil) Nil) ) Nil) ) Nil) )) ((TreeNode (Value K True AND) Nil (Cons (TreeNode (Value J True OR) Nil (Cons (TreeNode (Value I True LITERAL) (Cons (TreeNode (Value G False LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value H True OR) Nil Nil) Nil)) Nil)) Nil)) False))


;; Test for applyorcut function

!(assertEqual 
   (applyOrCut 
     (TreeNode (Value B False OR) Nil (Cons (TreeNode (Value C False LITERAL) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil) ) (Cons (TreeNode (Value D True LITERAL) Nil Nil) Nil) ) Nil) )
     (TreeNode (Value A True AND) (Cons (TreeNode (Value G0 True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value E False LITERAL) Nil Nil) Nil )) 
   )  
   (TreeNode (Value A True AND) (Cons (TreeNode (Value G0 True LITERAL) Nil Nil) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value E False LITERAL) Nil Nil) (Cons (TreeNode (Value D True LITERAL) Nil Nil) Nil)))
 )


;; Test for commandSetIterator function

;; ;; ! (assertEqual 
;;      (commandSetIterator 
;;        (TreeNode (Value D True AND) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) Nil)  Nil)
;;        (Cons (TreeNode (Value D True AND) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) Nil)  Nil) (Cons (TreeNode (Value E True AND) (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil)  Nil) (Cons (TreeNode (Value F True OR) Nil  (Cons (TreeNode (Value D True AND) (Cons (TreeNode (Value G1 True LITERAL) Nil Nil) Nil)  Nil) (Cons (TreeNode (Value E True AND) (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil)  Nil) Nil))) Nil)))
;;        Nil
;;      )
;;      (Cons (TreeNode (Value G2 True LITERAL) Nil Nil) Nil)
;;  )

;; ! (assertEqual (commandSetIterator NilNode Nil Nil) Nil)


;; Test for intersections function

;; !(assertEqual (intersections Nil) Nil)

;; !(assertEqual 
;;    (intersections  
;;      (Cons (TreeNode ( Value AND True AND) (Cons (TreeNode ( Value A True LITERAL) Nil Nil) (Cons (TreeNode ( Value B True LITERAL) Nil Nil) Nil)) Nil) Nil)
;;    )
;;    (Cons (TreeNode (Value A True LITERAL) Nil Nil) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil))
;;  )


;; Test for containsTerminalAndNode function

;; !(assertEqual 
;;    (containsTerminalAndNode 
;;      (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil)
;;    ) 
;;    False
;;  )

;; !(assertEqual 
;;    (containsTerminalAndNode 
;;      (Cons (TreeNode  (Value "D" False OR) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil) Nil) Nil)
;;    )
;;    False
;;  )

;; !(assertEqual 
;;    (containsTerminalAndNode 
;;      (Cons (TreeNode (Value "C" False AND) Nil (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value "B" False AND) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value "D" False OR) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil) Nil) Nil)))
;;    )
;;    True
;;  )

;; !(assertEqual 
;;    (containsTerminalAndNode 
;;      (Cons (TreeNode (Value "C" False AND) Nil (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value "D" False OR) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil) Nil) (Cons (TreeNode (Value "E" False AND) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" False AND) Nil (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil)) Nil)) Nil) Nil)))
;;    ) 
;;    False
;;  )


;; Test case for compareSets function

;; !(assertEqual 
;;    (compareSets 
;;      (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode (Value "B" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) Nil)))
;;      (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode (Value "B" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) Nil)))
;;    )
;;    True
;;  )

;; !(assertEqual 
;;    (compareSets 
;;      (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode  (Value "B" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) Nil)))
;;      (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode (Value "K" True LITERAL) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) Nil)))
;;    )
;;    False
;;  )


;; Test case for orSubTreeElegance function

;; !(assertEqual 
;;   (orSubTreeElegance 
;;      (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) 
;;      (TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil))) 
;;      (Cons (TreeNode (Value G7 False LITERAL) Nil Nil) Nil)
;;      (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
;;   ) 
;;   ((TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) Nil Nil) Nil))) DISCONNECT))


;; Test case for andSubTreeElegance function

;; !(assertEqual 
;;    (andSubTreeElegance 
;;      (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil)
;;      (TreeNode (Value S True AND) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil)))
;;      (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
;;      (Cons (TreeNode (Value G7 False LITERAL) Nil Nil) Nil)
;;    )
;;    ((TreeNode (Value S True AND) Nil (Cons (TreeNode (Value P True AND) Nil Nil) Nil)) ADVANCE)
;;  )


;; Test case for iterator function

;; !(assertEqual
;;    (iterator 
;;      (TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil))) 
;;      (Cons (TreeNode (Value G5 False LITERAL) Nil Nil) Nil)
;;      (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
;;    )
;;    ((TreeNode (Value R True OR) Nil Nil) NONE)
;;  )



;; Test case for orSubTreeIterator function

;; !(assertEqual
;;   (orSubTreeIterator 
;;     (TreeNode (Value P True AND) Nil Nil) 
;;     (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil) 
;;     (TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil)))
;;     (Cons (TreeNode (Value G5 False LITERAL) Nil Nil) Nil)
;;     (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
;;   )
;;   ((TreeNode (Value R True OR) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil))) DISCONNECT)
;; )


;; Test case for andSubTreeIterator
;; this should return None

;; !(assertEqual
;;   (andSubTreeIterator 
;;     (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil)) 
;;     (TreeNode (Value S True AND) Nil (Cons (TreeNode (Value P True AND) Nil Nil) (Cons (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) Nil)))
;;     (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
;;     (Cons (TreeNode (Value G7 False LITERAL) Nil Nil) Nil)
;;   )
;;   (NilNode None)
;;  )


;; Test case for reduceToElegance function

;; !(assertEqual
;;   (reduceToElegance 
;;     (TreeNode (Value Q True AND) (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil) Nil) 
;;     (Cons (TreeNode (Value G5 False LITERAL) Nil Nil) Nil)
;;     (Cons (TreeNode (Value G6 False LITERAL) Nil Nil) Nil)
;;   )
;;   ((TreeNode (Value Q True AND) Nil Nil) DISCONNECT)
;;  )
