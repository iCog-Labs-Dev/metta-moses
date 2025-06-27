
!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:reduct:enf)

;; Helper function for clean tree
(= (REDUCE $expr) (reduce $expr))
!(bind! tree1 (mkTree (mkNode AND)
                (Cons (mkTree (mkNode A) Nil)
                (Cons (mkTree (mkNode OR)
                        (Cons (mkTree (mkNode B) Nil)
                        (Cons (mkTree (mkNode C) Nil) Nil))) Nil))))
!(bind! tree2 (mkTree (mkNode AND)
            (Cons (mkTree (mkNode A) Nil)
            (Cons (mkTree (mkNode OR)
                    (Cons (mkTree (mkNode B) Nil)
                    (Cons (mkTree (mkNode C) Nil)
                    (Cons (mkNullVex Nil) Nil) ))) Nil))))

! (bind! tree3 (mkTree (mkNode AND)
            (Cons (mkTree (mkNode OR) 
                (Cons (mkTree (mkNode AND)
                    (Cons (mkTree (mkNode OR)
                        (Cons (mkTree (mkNode A) Nil) 
                        (Cons (mkTree (mkNode B) Nil) Nil))) 
                (Cons (mkTree (mkNode OR) 
                       (Cons (mkTree (mkNode C) Nil) 
                       (Cons (mkTree (mkNode D) Nil) Nil))) Nil))) 
                (Cons (mkTree (mkNode D) Nil) Nil))) 
                (Cons (mkTree (mkNode C) Nil) Nil))))

! (bind! tree4 (mkTree (mkNode OR) 
                (Cons (mkTree (mkNode A) Nil) 
                (Cons (mkTree (mkNode AND) 
                        (Cons (mkTree (mkNode A) Nil) 
                        (Cons (mkTree (mkNode B) Nil) Nil))) Nil))))
;; Tree preOrder traversal tests

!(assertEqual (preOrder (mkNullVex Nil)) ())
!(assertEqual (preOrder (mkTree (mkNode A) Nil)) A)
!(assertEqual (preOrder (mkTree (mkNode AND)
                            (Cons (mkTree (mkNode A) Nil) Nil))) (AND A))

!(assertEqual (preOrder (mkTree (mkNode AND)
                            (Cons (mkTree (mkNode A)
                                      (Cons (mkTree (mkNode B) Nil)
                                      (Cons (mkTree (mkNode C) Nil) Nil))) Nil))) (AND (A B C)))

!(assertEqual (preOrder (mkTree (mkNode AND)
                            (Cons (mkTree (mkNode A) Nil)
                            (Cons (mkTree (mkNode B) Nil)
                            (Cons (mkTree (mkNode C) Nil) Nil))))) (AND A B C))

!(assertEqual (preOrder tree1) (AND A (OR B C)))
!(assertEqual (preOrder tree2) (AND A (OR B C)))

;; ;; FIX: Commented out until the REDUCE issue is fixed.
;; !(assertEqual (cleanTree (mkTree (mkNode AND)
;;                             (Cons (mkTree (mkNode OR)
;;                                 (Cons (mkTree (mkNode A) Nil)
;;                                 (Cons (mkTree (mkNode B) Nil) Nil))) 
;;                                 (Cons (mkTree (mkNode A) Nil) Nil)))
;;                           )
;;                             (mkTree (mkNode AND) 
;;                               (Cons (mkTree (mkNode A) Nil) Nil)))
;; !(assertEqual (cleanTree (mkTree (mkNode AND) 
;;                             (Cons (mkTree (mkNode OR) 
;;                               (Cons (mkTree (mkNode A) Nil) 
;;                               (Cons (mkTree (mkNode B) Nil) Nil)))
;;                             (Cons (mkTree (mkNode NOT) 
;;                               (Cons (mkTree (mkNode A) Nil) Nil)) Nil)))
;;                           )
;;                             (mkTree (mkNode AND) 
;;                               (Cons (mkTree (mkNode NOT) 
;;                                 (Cons (mkTree (mkNode A) Nil) Nil))
;;                                 (Cons (mkTree (mkNode B) Nil) Nil))))
;; !(assertEqual (cleanTree (buildTree (AND (OR A B) (NOT A) (NOT B)))) (buildTree (AND (NOT A) (NOT B) (OR))))
;; !(assertEqual (cleanTree (buildTree (AND A B (NOT A)))) (buildTree (AND)))
;; !(assertEqual (cleanTree (buildTree (OR (AND A B (NOT A) B)))) (buildTree (AND)))
;; !(assertEqual (cleanTree (buildTree (OR A (AND B C)))) (buildTree (AND (OR (AND A) (AND B C)))))
;; !(assertEqual (cleanTree (buildTree (OR A B C D))) (buildTree (AND (OR (AND A) (AND B) (AND C) (AND D)))))

(: A Bool)

!(assertEqual (get-type tree1) (Tree Bool))
!(assertEqual (get-type tree2) (Tree Bool))


! (assertEqual (buildTree (AND (OR (AND (OR A B) (OR C D)) D) C)) tree3)
! (assertEqual (buildTree (OR A  (AND A B))) tree4)

;;Testcases for getSubtreeId
!(assertEqual
  (getSubtreeId
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                (Cons (mkTree (mkNode C) Nil) Nil)))Nil)))
    (mkNodeId (2))
    (mkTree (mkNode C) Nil)
    0)
  (mkNodeId (2 2)))

!(assertEqual
  (getSubtreeId
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                (Cons (mkTree (mkNode C) Nil) Nil)))Nil)))
    (mkNodeId (2))
    (mkTree (mkNode B) Nil)
    0)
  (mkNodeId (2 1)))

;;Testcases for getChildrenById
!(assertEqual
  (getChildrenById
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode S) Nil) Nil)) Nil))) Nil)))
    (mkNodeId (2 2)))
  (Cons (mkTree (mkNode S) Nil) Nil))

  !(assertEqual
  (getChildrenById
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode X) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode Y) Nil)
                  (Cons (mkNullVex
                          (Cons (mkTree (mkNode T) Nil) Nil)) Nil))) Nil)))
    (mkNodeId (2)))
  (Cons (mkTree (mkNode Y) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode T) Nil) Nil)) Nil)))

;;Testcases for insertAbove
!(assertEqual
  (insertAbove
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) (Cons (mkTree (mkNode Z) Nil) Nil))
                  (Cons (mkTree (mkNode C) Nil) Nil)))
          (Cons (mkTree (mkNode A) Nil) Nil))))
    (mkNode NOT))
  (mkTree (mkNode NOT)
    (Cons
      (mkTree (mkNode AND)
        (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) (Cons (mkTree (mkNode Z) Nil) Nil))
                    (Cons (mkTree (mkNode C) Nil) Nil)))
            (Cons (mkTree (mkNode A) Nil) Nil))))
      Nil)))

!(assertEqual
  (insertAbove
    (mkNullVex
      (Cons (mkTree (mkNode S) Nil)
        Nil))
    (mkNode NOT))
  (mkTree (mkNode NOT)
    (Cons
      (mkNullVex
        (Cons (mkTree (mkNode S) Nil)
          Nil))
      Nil)))

;;Testcases for replaceNodeById
!(assertEqual
  (replaceNodeById
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode X) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode Y) Nil)
                  (Cons (mkTree (mkNode Z) Nil)
                    Nil))) Nil)))
    (mkNodeId (2 2))
    (mkTree (mkNode W) Nil))
  (mkTree (mkNode AND)
    (Cons (mkTree (mkNode X) Nil)
      (Cons (mkTree (mkNode OR)
              (Cons (mkTree (mkNode Y) Nil)
                (Cons (mkTree (mkNode W) Nil) Nil))) Nil))))

!(assertEqual
  (replaceNodeById
    (mkTree (mkNode OR)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkNullVex
                (Cons (mkTree (mkNode S) Nil)
                  Nil))
          Nil)))
    (mkNodeId (2))
    (mkTree (mkNode B) Nil))
  (mkTree (mkNode OR)
    (Cons (mkTree (mkNode A) Nil)
      (Cons (mkTree (mkNode B) Nil)
        Nil))))

;; Test replaceNodeById at root with children
!(assertEqual
   (replaceNodeById 
      (mkTree (mkNode AND)
        (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                (Cons (mkTree (mkNode C) Nil)
                (Cons (mkNullVex
                        (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)))
      (mkNodeId (0))
      (mkTree (mkNode A) Nil))
   (mkTree (mkNode A) Nil))

;; Test replaceNodeById at root with no children
!(assertEqual
   (replaceNodeById
      (mkTree (mkNode AND) Nil)
      (mkNodeId (0))
      (mkTree (mkNode A) Nil))
   (mkTree (mkNode A) Nil))

;;Testcases for appendChild
!(assertEqual
  (appendChild
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                    Nil))) Nil)))
    (mkNodeId (1))
    (mkNullVex Nil))
  ((mkTree (mkNode AND)
     (Cons (mkTree (mkNode A)
             (Cons (mkNullVex Nil) Nil))
       (Cons (mkTree (mkNode OR)
               (Cons (mkTree (mkNode B) Nil)
                 (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))
   (mkNodeId (1 1))))

!(assertEqual
   (appendChild
      (mkTree (mkNode AND)
        (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                    (Cons (mkTree (mkNode C) Nil)
                      Nil)))
            Nil)))
      (mkNodeId (2))
      (mkTree (mkNode D) Nil))
   ((mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil)
                    (Cons (mkTree (mkNode D) Nil)
                      Nil))))
          Nil)))
    (mkNodeId (2 3))))

;; Test appendChild on empty null vertex
!(assertEqual
    (appendChild (mkNullVex Nil) (mkNodeId (1)) (mkTree (mkNode B) Nil))
    ((mkTree (mkNode B) Nil) (mkNodeId (0))))

;; Test appendChild on Null vertex with children
!(assertEqual
    (appendChild 
      (mkNullVex
         (Cons (mkTree (mkNode A) Nil) Nil)) 
         (mkNodeId (1))
         (mkTree (mkNode B) Nil))
    (Error (mkNullVex (Cons (mkTree (mkNode A) Nil) Nil)) "Null vertex can't have more than one child"))

;; Test appendChild on empty root node
!(assertEqual (appendChild (mkTree (mkNode AND) Nil) (mkNodeId (0)) (mkTree (mkNode B) Nil))
              ((mkTree (mkNode AND) (Cons (mkTree (mkNode B) Nil) Nil)) (mkNodeId (1))))

;; Test appendChild on non empty root node (AND A B C) => (AND A B C D)
!(assertEqual 
    (appendChild 
       (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode B) Nil)
          (Cons (mkTree (mkNode C) Nil) Nil))))
       (mkNodeId (0))
       (mkTree (mkNode D) Nil))
    (
      (mkTree (mkNode AND)
                (Cons (mkTree (mkNode A) Nil)
                (Cons (mkTree (mkNode B) Nil)
                (Cons (mkTree (mkNode C) Nil)
                (Cons (mkTree (mkNode D) Nil) Nil))))) 
      (mkNodeId (4))
    )
  )



;; Test cases for  getChildernByIdx
!(assertEqual (getChildrenByIdx (mkTree (mkNode A) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) Nil))) 0) (mkTree (mkNode B) Nil))
!(assertEqual (getChildrenByIdx (mkTree (mkNode X) (Cons (mkTree (mkNode Y) Nil) (Cons (mkTree (mkNode Z) Nil) Nil))) 1) (mkTree (mkNode Z) Nil))
!(assertEqual (getChildrenByIdx (mkNullVex (Cons (mkTree (mkNode P) Nil) (Cons (mkTree (mkNode Q) Nil) Nil))) 0) (mkTree (mkNode P) Nil))
!(assertEqual (getChildrenByIdx (mkNullVex (Cons (mkTree (mkNode R) Nil) (Cons (mkTree (mkNode S) Nil) Nil))) 1) (mkTree (mkNode S) Nil))


;; Test cases for isEmpty
! (assertEqual (isEmpty (mkNullVex Nil)) True)
! (assertEqual (isEmpty (mkTree (mkNode A) Nil)) False)
! (assertEqual (isEmpty (mkTree (mkNode B) (Cons NullVertex Nil))) False)
;; Test cases for getNodeId
;; (AND A (OR B C)) A
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))
      (mkTree (mkNode A) Nil))
    (mkNodeId (1))
 )

;; (AND A (OR B C)) B
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))
      (mkTree (mkNode B) Nil))
    (mkNodeId (2 1))
 )

;; (AND A (OR B (AND D E))) E
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode AND)
                          (Cons (mkTree (mkNode D) Nil)
                          (Cons (mkTree (mkNode E) Nil) Nil))) Nil))) Nil)))
      (mkTree (mkNode E) Nil))
    (mkNodeId (2 2 2))
 )

;; (AND A (OR B C)) D
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode AND)
                          (Cons (mkTree (mkNode D) Nil)
                          (Cons (mkTree (mkNode E) Nil) Nil))) Nil))) Nil)))
      (mkTree (mkNode D) Nil))
    (mkNodeId (2 2 1))
 )

;; (AND A (OR B C)) E
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))
      (mkTree (mkNode E) Nil))
    (mkNodeId (-1))
 )

;; (AND A (OR B C)) (AND A (OR B C))
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))
      (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil))) Nil))))
    (mkNodeId (0))
 )

;; (AND (A (OR B C))) (OR B C)
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
          (Cons (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))
      (mkTree (mkNode OR)
                  (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil))))
    (mkNodeId (2))
 )

;; Test case for isNullVertex
!(assertEqual (isNullVertex (mkNullVex Nil)) True)
!(assertEqual (isNullVertex (mkTree (mkNode A) Nil)) False)
!(assertEqual (isNullVertex (mkTree (mkNode B) (Cons (mkNullVex Nil) Nil))) False)

;; Test case for tree complexity
!(assertEqual (treeComplexity (buildTree (AND (NOT A) (OR A B)))) 3)
!(assertEqual (treeComplexity (mkNullVex (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) Nil))) 0)
!(assertEqual (treeComplexity (mkTree (mkNode OR) (Cons (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) Nil))) 1)

;; Test case for alphabetSize
! (bind! ttable1 (mkITable (Cons (Cons True (Cons False (Cons True Nil)))
                        (Cons (Cons True (Cons True  (Cons True Nil))) Nil)) 
                        (Cons A (Cons B (Cons O Nil)))))
! (bind! ttable2 (mkITable
                    (Cons (Cons True (Cons True (Cons True Nil)))
                    (Cons (Cons True (Cons False (Cons False Nil)))
                    (Cons (Cons False (Cons True (Cons False Nil)))
                    (Cons (Cons False (Cons False (Cons False Nil))) Nil))))
                    (Cons A (Cons B (Cons Output Nil)))))

! (assertEqual (alphabetSize ttable1) 5)
! (assertEqual (alphabetSize ttable2) 5)
; ! (assertEqual (alphabetSize 
;       (mkTree (mkNode AND) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode P) Nil) (Cons (mkTree (mkNode Q) Nil) Nil))) 
;           (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode P) Nil) Nil)) Nil)))) 
;       2)      
