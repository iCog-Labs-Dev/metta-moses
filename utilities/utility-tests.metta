! (register-module! ../../metta-moses-reduction)
! (import! &self metta-moses-reduction:types)
! (import! &self metta-moses-reduction:utilities:expression-helpers)
! (import! &self metta-moses-reduction:utilities:list-helpers)
! (import! &self metta-moses-reduction:utilities:tree-helpers)
! (import! &self metta-moses-reduction:enf-reducer:RTEHelpers)

;; -----------------------------------
;; -----------------------------------
;; Test cases for experssion-helpers.metta
;; -----------------------------------
;; -----------------------------------

; !(checkTreeDepth (AND (OR x1 x2) (AND x3 x4)))

; !(getChildren (AND (OR x1 x2) (AND x3 x4)) Nil)

; !(getGuardSet (AND (OR x1 x2) (AND x3 x4)))

; !(nAryOr (Cons False (Cons True (Cons False (Cons True Nil)))))

;; -----------------------------------
;; -----------------------------------
;; Test cases for list-helpers.metta
;; -----------------------------------
;; -----------------------------------

; !(length (Cons A (Cons B (Cons C Nil))))

; !(index 2 (Cons A (Cons B (Cons C Nil))))

; (= (add1 $num) (+ $num 1))
; !(map add1 (Cons 1 (Cons 2 (Cons 3 Nil))))

; !(memberWith == 4 (Cons 1 (Cons 2 (Cons 3 Nil))))

; !(member B (Cons A (Cons B (Cons C Nil))))
; !(member 1 Nil)

; !(append (Cons a (Cons b (Cons c Nil))) (Cons c Nil))

; !(removeDuplicates (Cons A (Cons B (Cons B Nil))))

; !(any (Cons False Nil)) ;; False
; !(any (Cons True Nil)) ;; True
; !(any (Cons True(Cons False (Cons True Nil)))) ;; True

; !(all (Cons False Nil)) ;; False
; !(all (Cons True Nil)) ;; True
; !(all (Cons False(Cons True (Cons False Nil)))) ;; False
; !(all (Cons True(Cons True (Cons True Nil)))) ;; True

; !(findAndRemove 1 (Cons 1 (Cons 2 (Cons 3 Nil))))  ;; Output: [(Cons 2 (Cons 3 Nil))]
; !(findAndRemove 3 (Cons 1 (Cons 2 (Cons 3 Nil))))  ;; Output: [(Cons 1 (Cons 2 Nil))]
; !(findAndRemove 4 (Cons 1 (Cons 2 (Cons 3 Nil))))  ;; Output: [(Cons 1 (Cons 2 (Cons 3 Nil)))]

; !(compare (Cons 1 Nil) (Cons 1 Nil)) ;; Output: True
; !(compare (Cons "A" Nil) (Cons "a" Nil)) ;; Output: False
; !(compare (Cons 1 (Cons 2 (Cons 3 Nil))) (Cons 1 (Cons 2 (Cons 3 Nil)))) ;; Output: True
; !(compare (Cons 1 (Cons 2 (Cons 3 Nil))) (Cons 1  (Cons 2 Nil)) ) ;; Output: False

; !(isSubset (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 2 (Cons 3  Nil))))

; !(unionSet (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) )

; !(intersect (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 5 (Cons 6 (Cons 7 (Cons 1 Nil)))) Nil)
; !(intersect (Cons 1 (Cons 2 (Cons 3 (Cons 4 Nil)))) (Cons 1 (Cons 4 (Cons 5 (Cons 6 Nil)))) Nil)
; !(intersect (Cons a (Cons b (Cons c Nil))) (Cons c (Cons d (Cons e (Cons f Nil)))) Nil)

; !(nAryOr (Cons False (Cons True (Cons False (Cons True Nil)))))

; !(nAryAnd (Cons True (Cons True (Cons False (Cons True Nil)))))

;; main = print $ mergeSort [3, 6, 2, 7, 1, 5, 4]
; !(quickSort (Cons 2 (Cons 1 (Cons 3 Nil))))
; !(quickSort (Cons 3 (Cons 6 (Cons 2 (Cons 7 (Cons 1 (Cons 5 (Cons 4 Nil))))))))


; !(hasTerminalNode (TreeNode (Value Nil False OR) (TreeNode (Value Nil True AND) NilNode NilNode NilList NilList) (TreeNode (Value Nil False AND) NilNode (TreeNode (Value Nil False AND) NilNode NilNode (ConsTree (TreeNode (Value x True LITERAL) NilNode NilNode NilList NilList ) (ConsTree (TreeNode (Value x True LITERAL) NilNode NilNode NilList NilList ) NilList)) NilList) NilList NilList) NilList NilList) )

; !(hasTerminalNode (= tree1
;   (TreeNode
;     (Value Nil False AND)
;     (TreeNode
;       (Value x False LITERAL)
;       NilNode
;       NilNode
;       NilList
;       NilList
;     )
;     (TreeNode
;       (Value Nil False AND)
;       NilNode
;       NilNode
;       (ConsTree
;         (TreeNode
;           (Value b False LITERAL)
;           NilNode
;           NilNode
;           NilList
;           NilList
;         )
;         NilList
;       )
;       NilList
;     )
;     NilList
;   )
; )
;  )

; !(hasTerminalNode (TreeNode (Value Nil False AND) (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) (TreeNode (Value Nil False AND) (TreeNode (Value NilNode False OR) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList) (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList) NilList NilList) NilList NilList) ) 

; !(hasTerminalNode (TreeNode (Value Nil False AND)
;     (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList)
;     (TreeNode (Value Nil False AND)
;         (TreeNode (Value NilNode False OR) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList)
;         (TreeNode (Value NilNode False AND) 
;             (TreeNode (Value Nil False AND)
;             (TreeNode (Value NilNode False AND) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList)
;             (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList)
;                 NilList
;                 NilList
;             ) 
;             NilNode NilList NilList)
;         NilList
;         NilList
;     )
;     NilList
;     NilList
; )
; )

; !(hasTerminalNode (TreeNode
;   (Value Nil False AND)
;   (TreeNode
;     (Value x False LITERAL)
;     NilNode
;     NilNode
;     NilList
;     NilList
;   )
;   (TreeNode
;     (Value Nil False AND)
;     NilNode
;     NilNode
;     (ConsTree
;       (TreeNode
;         (Value b False LITERAL)
;         NilNode
;         NilNode
;         NilList
;         NilList
;       )
;       NilList
;     )
;     NilList
;   )
;   NilList
; )
; )


; !(containsTerminalNode
; (ConsTree 
;     (TreeNode (Value Nil False AND) (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) (TreeNode (Value Nil False AND) (TreeNode (Value NilNode False AND) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList) (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList) NilList NilList) NilList NilList) 
;     (ConsTree (TreeNode (Value Nil False AND)
;     (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList)
;     (TreeNode (Value Nil False AND)
;         (TreeNode (Value NilNode False OR) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList)
;         (TreeNode (Value NilNode False AND) 
;             (TreeNode (Value Nil False AND)
;             (TreeNode (Value NilNode False AND) NilNode NilNode (ConsTree (TreeNode (Value x False LITERAL) NilNode NilNode NilList NilList) NilList ) NilList) ;this node fulfills the condition
;             (TreeNode (Value NilNode False AND) NilNode NilNode NilList NilList)
;                 NilList
;                 NilList
;             ) 
;             NilNode NilList NilList)
;         NilList
;         NilList
;     )
;     NilList
;     NilList
; ) NilList)
;     )
;  )


;; -----------------------------------
;; -----------------------------------
;; Test cases for tree-helpers.metta
;; -----------------------------------
;; -----------------------------------

; !(buildTree (AND a b))
; !(buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A))))))))

; !(getChild (buildTree b) L)
; !(getChild (buildTree (AND a b)) R)

; !(getChildren (buildTree (AND a b)))

; !(getGuardSet (buildTree (AND a b)))

; !(replaceChild (buildTree (NOT A)) (buildTree (OR Y Z)) L)

; !(appendChild (buildTree A) (buildTree (AND B)) )
; !(appendChild
;;		(TreeNode (Value Nil False AND) 
;;					(TreeNode (Value A False LITERAL) NilNode NilNode NilList NilList)
;;					(TreeNode (Value B False LITERAL) NilNode NilNode NilList NilList)
;;			NilList
;;			(ConsTree 
;;							(TreeNode (Value Nil False AND) 
;;									(TreeNode (Value C False LITERAL) NilNode NilNode NilList NilList) 
;;									(TreeNode (Value D False LITERAL) NilNode NilNode NilList NilList) NilList NilList)
;;							NilList
;;			) 
;;		)
;;
;;		(buildTree (AND Y Z))
;;	)

; !(nodeEquality (buildTree (AND A B)) (buildTree (AND A B)))

; !(treeIsMember (buildTree D) (getChildren (buildTree (AND A D))))

; !(treeIntersection (getChildren (buildTree (AND A B))) (getChildren (buildTree (AND D E))))

; !(compareTrees (buildTree (OR a (AND b c))) (buildTree (AND d (AND b c))))

; !(compareAndRemoveNode (buildTree (OR a (AND b c))) (ConsTree (buildTree (OR a (AND b c))) (ConsTree (buildTree (AND a (AND b c))) NilList)) NilList)

;; (= (zip $x $y) ($x $y))

;; !(treeFoldl zip Nil (buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A)))))))))
;; !(treeFoldr zip Nil (buildTree (AND A (AND B (AND C (AND (OR A (OR B (OR C A))) (AND B (AND (AND A A) (NOT A)))))))))

;; -----------------------------------
;; -----------------------------------
;; Test cases for RTEHelpers.metta
;; -----------------------------------
;; -----------------------------------

!(disconnectSubTreeHandler 
  (buildTree (OR a (AND b c))) 
  (TreeNode 
    (Value Nil False OR)
    Nil
    (Cons 
      (buildTree (OR a (AND b c))) 
      (Cons 
        (buildTree (AND a (AND b c)))
        Nil
      )
    )
  )
)
