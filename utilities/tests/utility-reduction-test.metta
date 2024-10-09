! (register-module! ../../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:utilities:general-helper-functions)
! (import! &self metta-moses-reduction:enf-reducer:rte-helpers)
! (import! &self metta-moses-reduction:enf-reducer:reduce-to-elegance)

;; This test file is will only be useful for testing the reduction of some functions. It doesn't contains assert statements.

;; Test cases for list-helpers.metta

;; !(length (Cons A (Cons B (Cons C Nil))))

;; !(head Nil)
;; !(head (Cons (TreeNode (Value "A" True OR) Nil Nil) (Cons (TreeNode (Value "B" False LITERAL) Nil Nil) Nil)))

;; !(tail Nil)
;; !(tail (Cons (TreeNode (Value "A" True OR) Nil Nil) (Cons (TreeNode (Value "B" False LITERAL) Nil Nil) Nil)))

;; !(index 2 (Cons A (Cons B (Cons C Nil))))

;; (= (add1 $num) (+ $num 1))
;; !(map add1 (Cons 1 (Cons 2 (Cons 3 Nil))))

;; !(memberWith == 4 (Cons 1 (Cons 2 (Cons 3 Nil))))

;; !(member B (Cons A (Cons B (Cons C Nil))))
;; !(member 1 Nil)

;; !(append (Cons a (Cons b (Cons c Nil))) (Cons c Nil))

;; !(removeDuplicates (Cons A (Cons B (Cons B Nil))))

;;  ! (removeAtIndex 2 (Cons A (Cons B (Cons C (Cons D (Cons E Nil))))))
;;  ! (removeAtIndex 0 (Cons A (Cons B (Cons C (Cons D (Cons E Nil))))))

;;  ! (replaceAtIndex 4 H (Cons A (Cons B (Cons C (Cons D (Cons E Nil))))))
;;  ! (replaceAtIndex 1 H (Cons A (Cons B (Cons C (Cons D (Cons E Nil))))))

;; !(isSubset (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 2 (Cons 3  Nil))))

;; !(setUnion (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) )

;; !(intersect (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) Nil)
;; !(intersect (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 4 (Cons 5 (Cons 6 Nil)))) Nil)
j; !(intersect (Cons a (Cons b (Cons c Nil))) (Cons c (Cons d (Cons e (Cons f Nil)))) Nil)

;; !(setDifference member (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) Nil)
;; !(setDifference member (Cons a (Cons b (Cons c Nil))) (Cons c (Cons d (Cons e (Cons f Nil)))) Nil)
;; !(setDifference treeIsMember (Cons (buildTree (AND A (AND B))) (Cons (buildTree (AND E (AND D))) (Cons (buildTree (AND F (AND G))) Nil))) (Cons (buildTree (AND A (AND B))) (Cons (buildTree (AND C (AND F))) (Cons (buildTree (AND F (AND G))) (Cons (buildTree (AND A (AND B))) Nil)))) Nil)
;; !(setDifference treeIsMember (getChildren (buildTree (AND D B))) (getChildren (buildTree (OR A C))) Nil)
;; !(setDifference treeIsMember Nil (getChildren (buildTree (OR A C))) Nil)
;; !(setDifference treeIsMember (getChildren (buildTree (OR A C))) Nil Nil)

;; !(nAryOr (Cons False (Cons True (Cons False (Cons True Nil)))))

;; !(nAryAnd (Cons True (Cons True (Cons False (Cons True Nil)))))

;; !(quickSort (Cons 2 (Cons 1 (Cons 3 Nil))))
;; !(quickSort (Cons 3 (Cons 6 (Cons 2 (Cons 7 (Cons 1 (Cons 5 (Cons 4 Nil))))))))


;; Test cases for tree-helpers.metta

;; !(buildTree (AND a b))
;; !(buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))

;; !(getChild (buildTree b) L)
;; !(getChild (buildTree (AND a b)) R)

;; !(getChildren (buildTree (AND a b)))

;; !(getGuardSet (buildTree (AND a b)))

;; !(replaceChild (buildTree (NOT A)) (buildTree (OR Y Z)) L)

;; !(appendChild (buildTree A) (buildTree (AND B)) )

;; !(isNodeEqual (buildTree (AND A B)) (buildTree (AND A B)))

;; !(treeIsMember (buildTree D) (getChildren (buildTree (AND A D))))

;; !(setIntersection treeIsMember (getChildren (buildTree (AND A B))) (getChildren (buildTree (AND D E))))

;; !(compareTrees (buildTree (OR a (AND b c))) (buildTree (AND d (AND b c))))

;; !(compareAndRemoveNode (buildTree (OR a (AND b c))) (ConsTree (buildTree (OR a (AND b c))) (ConsTree (buildTree (AND a (AND b c))) NilList)) NilList)

;; (= (zip $x $y) ($x $y))

;; !(computeGrandChildGuardSet
;;    (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) Nil)))
;;   (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) Nil))) Nil)
;;  )

;; !(computeGrandChildGuardSet
;;    (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) (Cons (TreeNode (Value E False LITERAL) Nil Nil) Nil)) (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) Nil))) 
;;    (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B False LITERAL) Nil Nil) (Cons (TreeNode (Value C False LITERAL) Nil Nil) Nil))) Nil))) Nil)
;;   )

;; !(isConsistent
;;    (Cons (TreeNode (Value "A" True AND) Nil (Cons (TreeNode (Value "B" True OR) Nil Nil) (Cons (TreeNode (Value "C" False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value "B" True OR) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) Nil))))
;;  )

;; !(isConsistent
;;   (Cons (TreeNode (Value "C" False AND) Nil (Cons (TreeNode (Value "B" True OR) Nil Nil) (Cons (TreeNode (Value "C" False LITERAL) Nil Nil) Nil))) (Cons (TreeNode (Value "B" True OR) Nil Nil) (Cons (TreeNode (Value "C" True LITERAL) Nil Nil) (Cons (TreeNode (Value "A" True LITERAL) Nil Nil) (Cons (TreeNode (Value "B" True OR) Nil Nil) (Cons (TreeNode (Value "C" False LITERAL) Nil Nil) Nil))))))
;;  )

;; !(detectConsistency (TreeNode (Value "d" True AND) Nil Nil)
;;   (Cons (TreeNode (Value "A" False AND) Nil Nil) (Cons (TreeNode (Value "B" True OR) Nil Nil) (Cons (TreeNode (Value "d" False LITERAL) Nil Nil) Nil)))
;;  )

;; !(detectConsistency 
;;    (TreeNode (Value "d" False AND) Nil Nil) 
;;    (Cons (TreeNode (Value "A" False AND) Nil Nil) (Cons (TreeNode (Value "B" True OR) Nil Nil) (Cons (TreeNode (Value "d" False LITERAL) Nil Nil) Nil)))
;;  )
 
;; !(containsTerminalAndNode (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value A False LITERAL) Nil Nil) Nil) Nil) Nil))
;; !(containsTerminalAndNode (Cons (TreeNode (Value Nil False OR) Nil Nil) Nil))

 ;; Test cases for RTEHelpers.metta

;;!(disconnectSubTreeHandler
;;    (buildTree (OR a (AND b c)))
;;    (TreeNode (Value Nil False OR) Nil (Cons (buildTree (OR a (AND b c))) (Cons (buildTree (AND a (AND b c))) Nil)))
;;  )


;;!(applyAndCut
;;       (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A False AND) Nil Nil) (Cons (TreeNode (Value B False AND) Nil Nil) Nil))) Nil))
;;       (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A False AND) Nil Nil) (Cons (TreeNode (Value B False AND) Nil Nil) Nil))) Nil)) (Cons (TreeNode (Value A False AND) Nil Nil) (Cons (TreeNode (Value B False AND) Nil Nil) Nil))))
;;  )

;; !(applyAndCut
;;     (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A False AND) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value B False AND) Nil Nil) Nil)) Nil)))
;;     (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B False AND) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A False AND) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value B False AND) Nil Nil) Nil)) Nil))) Nil))
;;  )
 
;;!(applyOrCut 
;;     (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B True LITERAL) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil)) Nil)) Nil))
;;     (TreeNode (Value A True LITERAL) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value B True LITERAL) Nil (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil)) Nil)) Nil)) Nil))
;; )
;; ;; !(applyOrCut 
;;     (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) Nil)) 
;;     (TreeNode (Value Nil False AND) (Cons (TreeNode (Value B True LITERAL) Nil Nil) Nil) (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) Nil)) (Cons (TreeNode (Value Nil False AND) (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil) Nil) Nil)))
;;  )

;; !(getChildren (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value A False AND) Nil Nil) Nil)) (Cons (TreeNode (Value Nil False AND) Nil (Cons (TreeNode (Value B False AND) Nil Nil) Nil)) Nil))))

;; !(prependChild (TreeNode (Value D False LITERAL) Nil Nil)  (TreeNode (Value K False LITERAL) Nil Nil) )

;;!(applyOrCutToChildren 
;;   (TreeNode (Value D False LITERAL) Nil Nil) 
;;   (Cons (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil)) Nil)
;; )
;; !(applyOrCutToChildren (TreeNode (Value Nil False OR) Nil (Cons (TreeNode (Value D False LITERAL) Nil Nil) Nil)) Nil)


;; !(findAndReplace
;;   (TreeNode (Value A False LITERAL) Nil Nil) 
;;   (TreeNode (Value B True LITERAL) Nil Nil) 
;;   (Cons (TreeNode (Value A False LITERAL) Nil Nil) (Cons (TreeNode (Value X False LITERAL) Nil Nil) Nil))
;;  )
;; !(findAndReplace
;;  (TreeNode (Value B True LITERAL) Nil Nil) 
;;  (TreeNode (Value A False LITERAL) Nil Nil) 
;;  (Cons (TreeNode (Value B True LITERAL) Nil Nil) (Cons (TreeNode (Value X False LITERAL) Nil Nil) Nil))
;;)

;; !(decoupleAndCutOutput ((TreeNode (Value C False LITERAL) Nil Nil) False)) 

;; !(map decoupleAndCutOutput (Cons ((TreeNode (Value C False LITERAL) Nil Nil) False) Nil))
;; !(map getChildren (Cons (TreeNode (Value C False LITERAL) Nil Nil) (Cons (TreeNode (Value D True LITERAL) Nil Nil) Nil) ))

;; !(any (map decoupleAndCutOutput (Cons ((TreeNode (Value C False LITERAL) Nil Nil) False) Nil)))

;; !(findAndRemoveTree (TreeNode (Value A False LITERAL) Nil  Nil) (Cons (TreeNode (Value A False LITERAL) Nil  Nil) Nil))

;; !(setInsert == (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) 1)
;; !(setInsert == (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) 5)
