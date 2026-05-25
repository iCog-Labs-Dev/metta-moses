!(import! &self ../general-helpers)
!(import! &self ../list-methods)
!(import! &self ../nodeId)
!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)
!(import! &self ../tree)
;; Helper function for clean tree

!(bind! tree1 (new-state (mkTree (mkNode AND)
                (cons (mkTree (mkNode A) ())
                (cons (mkTree (mkNode OR)
                        (cons (mkTree (mkNode B) ())
                        (cons (mkTree (mkNode C) ()) ()))) ())))))
!(bind! tree2 (new-state (mkTree (mkNode AND)
            (cons (mkTree (mkNode A) ())
            (cons (mkTree (mkNode OR)
                    (cons (mkTree (mkNode B) ())
                    (cons (mkTree (mkNode C) ())
                    (cons (mkNullVex ()) ()) ))) ())))))
!(bind! tree3 (new-state (mkTree (mkNode AND)
            (cons (mkTree (mkNode OR) 
                (cons (mkTree (mkNode AND)
                    (cons (mkTree (mkNode OR)
                        (cons (mkTree (mkNode A) ()) 
                        (cons (mkTree (mkNode B) ()) ()))) 
                (cons (mkTree (mkNode OR) 
                       (cons (mkTree (mkNode C) ()) 
                       (cons (mkTree (mkNode D) ()) ()))) ()))) 
                (cons (mkTree (mkNode D) ()) ()))) 
                (cons (mkTree (mkNode C) ()) ())))))
!(bind! tree4 (new-state (mkTree (mkNode OR) 
                (cons (mkTree (mkNode A) ()) 
                (cons (mkTree (mkNode AND) 
                        (cons (mkTree (mkNode A) ()) 
                        (cons (mkTree (mkNode B) ()) ()))) ())))))
;; Tree preOrder traversal tests

!(println! ("testing: preOrder"))
!(assertEqual (preOrder (mkNullVex ())) ())
!(assertEqual (preOrder (mkTree (mkNode A) ())) A)
!(assertEqual (preOrder (mkTree (mkNode AND)
                            (cons (mkTree (mkNode A) ()) ()))) (AND A))

!(assertEqual (preOrder (mkTree (mkNode AND)
                            (cons (mkTree (mkNode A)
                                      (cons (mkTree (mkNode B) ())
                                      (cons (mkTree (mkNode C) ()) ()))) ()))) (AND (A B C)))

!(assertEqual (preOrder (mkTree (mkNode AND)
                            (cons (mkTree (mkNode A) ())
                            (cons (mkTree (mkNode B) ())
                            (cons (mkTree (mkNode C) ()) ()))))) (AND A B C))


!(assertEqual (preOrder (get-state tree1)) (AND A (OR B C)))
!(assertEqual (preOrder (get-state tree2)) (AND A (OR B C)))
!(assertEqual (preOrder (buildTree (AND (OR (AND (OR (AND) (AND))) (AND (OR (NOT X1))))))) (AND (OR (AND (OR (AND) (AND))) (AND (OR (NOT X1))))))



!(assertEqual (cleanTree (mkTree (mkNode AND)
                            (cons (mkTree (mkNode OR)
                                (cons (mkTree (mkNode A) ())
                                (cons (mkTree (mkNode B) ()) ()))) 
                            (cons (mkTree (mkNode A) ()) ())))
                          )
                            (mkTree (mkNode A) ()))
!(assertEqual (cleanTree (mkTree (mkNode AND) 
                            (cons (mkTree (mkNode OR) 
                              (cons (mkTree (mkNode A) ()) 
                              (cons (mkTree (mkNode B) ()) ())))
                            (cons (mkTree (mkNode NOT) 
                              (cons (mkTree (mkNode A) ()) ())) ())))
                          )
                   (mkTree (mkNode AND)
                      (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode A) ()) ()))
                      (cons (mkTree (mkNode B) ()) ()))))
!(assertEqual (cleanTree (buildTree (AND (OR A B) (NOT A) (NOT B)))) (buildTree (AND (NOT A) (NOT B))))
!(assertEqual (cleanTree (buildTree (AND A B (NOT A)))) (buildTree (AND)))
!(assertEqual (cleanTree (buildTree (OR (AND A B (NOT A) B)))) (buildTree (AND)))
!(assertEqual (cleanTree (buildTree (OR A (AND B C)))) (buildTree (AND (OR A (AND B C)))))
!(assertEqual (cleanTree (buildTree (OR A B C D))) (buildTree (AND (OR A B C D))))

;; ;; type system is not working properly in mettalog 
;; ; (: A Bool)

;; !(assertEqual (get-type tree1) (Tree Bool))
;; !(assertEqual (get-type tree2) (Tree Bool))

!(println! ("testing: buildTree"))
!(assertEqual (buildTree (AND (OR (AND (OR A B) (OR C D)) D) C)) (get-state tree3))
!(assertEqual (buildTree (OR A  (AND A B))) (get-state tree4))

;;Testcases for getSubtreeId
!(println! ("testing: getSubtreeId"))
!(assertEqual
  (getSubtreeId
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) ())
                (cons (mkTree (mkNode C) ()) ())))())))
    (mkNodeId (2))
    (mkTree (mkNode C) ())
    0)
  (mkNodeId (2 2)))

!(assertEqual
  (getSubtreeId
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) ())
                (cons (mkTree (mkNode C) ()) ())))())))
    (mkNodeId (2))
    (mkTree (mkNode B) ())
    0)
  (mkNodeId (2 1)))

;;Testcases for getChildrenById
!(println! ("testing: getChildrenById"))
!(assertEqual
  (getChildrenById
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) ())
                  (cons (mkNullVex
                          (cons (mkTree (mkNode S) ()) ())) ()))) ())))
    (mkNodeId (2 2)))
  (cons (mkTree (mkNode S) ()) ()))

!(println! ("testing: getChildrenById"))
!(assertEqual
  (getChildrenById
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode X) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode Y) ())
                  (cons (mkNullVex
                          (cons (mkTree (mkNode T) ()) ())) ()))) ())))
    (mkNodeId (2)))
  (cons (mkTree (mkNode Y) ()) (cons (mkNullVex (cons (mkTree (mkNode T) ()) ())) ())))

; ;;Testcases for insertAbove
!(println! ("testing: insertAbove"))
!(assertEqual
  (insertAbove
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) (cons (mkTree (mkNode Z) ()) ()))
                  (cons (mkTree (mkNode C) ()) ())))
          (cons (mkTree (mkNode A) ()) ()))))
    (mkNode NOT))
  (mkTree (mkNode NOT)
    (cons
      (mkTree (mkNode AND)
        (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) (cons (mkTree (mkNode Z) ()) ()))
                    (cons (mkTree (mkNode C) ()) ())))
            (cons (mkTree (mkNode A) ()) ()))))
      ())))

!(assertEqual
  (insertAbove
    (mkNullVex
      (cons (mkTree (mkNode S) ())
        ()))
    (mkNode NOT))
  (mkTree (mkNode NOT)
    (cons
      (mkNullVex
        (cons (mkTree (mkNode S) ())
          ()))
      ())))

;;Testcases for replaceNodeById
!(println! ("testing: replaceNodeById"))
!(assertEqual
  (replaceNodeById
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode X) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode Y) ())
                  (cons (mkTree (mkNode Z) ())
                    ()))) ())))
    (mkNodeId (2 2))
    (mkTree (mkNode W) ()))
  (mkTree (mkNode AND)
    (cons (mkTree (mkNode X) ())
      (cons (mkTree (mkNode OR)
              (cons (mkTree (mkNode Y) ())
                (cons (mkTree (mkNode W) ()) ()))) ()))))

!(assertEqual
  (replaceNodeById
    (mkTree (mkNode OR)
      (cons (mkTree (mkNode A) ())
        (cons (mkNullVex
                (cons (mkTree (mkNode S) ())
                  ()))
          ())))
    (mkNodeId (2))
    (mkTree (mkNode B) ()))
  (mkTree (mkNode OR)
    (cons (mkTree (mkNode A) ())
      (cons (mkTree (mkNode B) ())
        ()))))

;; Test replaceNodeById at root with children
!(assertEqual
   (replaceNodeById 
      (mkTree (mkNode AND)
        (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) ())
                (cons (mkTree (mkNode C) ())
                (cons (mkNullVex
                        (cons (mkTree (mkNode D) ()) ())) ())))) ())))
      (mkNodeId (0))
      (mkTree (mkNode A) ()))
   (mkTree (mkNode A) ()))

;; Test replaceNodeById at root with no children
!(assertEqual
   (replaceNodeById
      (mkTree (mkNode AND) ())
      (mkNodeId (0))
      (mkTree (mkNode A) ()))
   (mkTree (mkNode A) ()))

; ;;Testcases for appendChild 
!(println! ("testing: appendChild"))
!(assertEqual
  (appendChild
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ())
                    ()))) ())))
    (mkNodeId (1))
    (mkNullVex ()))
  ((mkTree (mkNode AND)
     (cons (mkTree (mkNode A)
             (cons (mkNullVex ()) ()))
       (cons (mkTree (mkNode OR)
               (cons (mkTree (mkNode B) ())
                 (cons (mkTree (mkNode C) ()) ()))) ())))
   (mkNodeId (1 1))))

!(assertEqual
   (appendChild
      (mkTree (mkNode AND)
        (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                    (cons (mkTree (mkNode C) ())
                      ())))
            ())))
      (mkNodeId (2))
      (mkTree (mkNode D) ()))
   ((mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ())
                    (cons (mkTree (mkNode D) ())
                      ()))))
          ())))
    (mkNodeId (2 3))))

;; Test appendChild on empty null vertex
!(assertEqual
    (appendChild (mkNullVex ()) (mkNodeId (1)) (mkTree (mkNode B) ()))
    ((mkTree (mkNode B) ()) (mkNodeId (0))))

;; Test appendChild on Null vertex with children
!(assertEqual
    (appendChild 
      (mkNullVex
         (cons (mkTree (mkNode A) ()) ())) 
         (mkNodeId (1))
         (mkTree (mkNode B) ()))
    (Error (mkNullVex (cons (mkTree (mkNode A) ()) ())) "Null vertex can't have more than one child"))

;; Test appendChild on empty root node
!(assertEqual (appendChild (mkTree (mkNode AND) ()) (mkNodeId (0)) (mkTree (mkNode B) ()))
              ((mkTree (mkNode AND) (cons (mkTree (mkNode B) ()) ())) (mkNodeId (1))))

;; Test appendChild on non empty root node (AND A B C) => (AND A B C D)
!(assertEqual 
    (appendChild 
       (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode B) ())
          (cons (mkTree (mkNode C) ()) ()))))
       (mkNodeId (0))
       (mkTree (mkNode D) ()))
    (
      (mkTree (mkNode AND)
                (cons (mkTree (mkNode A) ())
                (cons (mkTree (mkNode B) ())
                (cons (mkTree (mkNode C) ())
                (cons (mkTree (mkNode D) ()) ()))))) 
      (mkNodeId (4))
    )
  )



; Test cases for  getChildernByIdx
!(println! ("testing getChildrenByIdx"))
!(assertEqual (getChildrenByIdx (mkTree (mkNode A) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ()))) 0) (mkTree (mkNode B) ()))
!(assertEqual (getChildrenByIdx (mkTree (mkNode X) (cons (mkTree (mkNode Y) ()) (cons (mkTree (mkNode Z) ()) ()))) 1) (mkTree (mkNode Z) ()))
!(assertEqual (getChildrenByIdx (mkNullVex (cons (mkTree (mkNode P) ()) (cons (mkTree (mkNode Q) ()) ()))) 0) (mkTree (mkNode P) ()))
!(assertEqual (getChildrenByIdx (mkNullVex (cons (mkTree (mkNode R) ()) (cons (mkTree (mkNode S) ()) ()))) 1) (mkTree (mkNode S) ()))

;; Testcases for insertNodeAtPosition
!(println! ("testing: insertNodeAtPosition"))
!(assertEqual
  (insertNodeAtPosition 
   (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) (cons (mkTree (mkNode Z) ()) ()))
                  (cons (mkTree (mkNode C) ()) ())))
          (cons (mkTree (mkNode A) ()) ())))) 
    (mkNodeId (2))
    (mkNode C))
  (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode C) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) (cons (mkTree (mkNode Z) ()) ())) (cons (mkTree (mkNode C) ()) ()))) ())) (cons (mkTree (mkNode A) ()) ())))))

  !(assertEqual
    (insertNodeAtPosition 
   (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) (cons (mkTree (mkNode Z) ()) ()))
                  (cons (mkTree (mkNode C) ()) ())))
          (cons (mkTree (mkNode A) ()) ())))) 
    (mkNodeId (0))
    (mkNode OR))
   (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) (cons (mkTree (mkNode Z) ()) ())) (cons (mkTree (mkNode C) ()) ()))) (cons (mkTree (mkNode A) ()) ())))) ()))
  )

;; Test cases for isEmpty
!(println! ("testing: isEmpty"))
!(assertEqual (isEmpty (mkNullVex ())) True)
!(assertEqual (isEmpty (mkTree (mkNode A) ())) False)
!(assertEqual (isEmpty (mkTree (mkNode B) (cons NullVertex ()))) False)
;; Test cases for getNodeId
;; (AND A (OR B C)) A
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ()))) ())))
      (mkTree (mkNode A) ()))
    (mkNodeId (1))
 )

; ;; (AND A (OR B C)) B
!(println! ("testing: getNodeId"))
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ()))) ())))
      (mkTree (mkNode B) ()))
    (mkNodeId (2 1))
 )

;; (AND A (OR B (AND D E))) E
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode AND)
                          (cons (mkTree (mkNode D) ())
                          (cons (mkTree (mkNode E) ()) ()))) ()))) ())))
      (mkTree (mkNode E) ()))
    (mkNodeId (2 2 2))
 )

;; (AND A (OR B C)) D
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode AND)
                          (cons (mkTree (mkNode D) ())
                          (cons (mkTree (mkNode E) ()) ()))) ()))) ())))
      (mkTree (mkNode D) ()))
    (mkNodeId (2 2 1))
 )

;; (AND A (OR B C)) E
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ()))) ())))
      (mkTree (mkNode E) ()))
    (mkNodeId (-1))
 )

;; (AND A (OR B C)) (AND A (OR B C))
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ()))) ())))
      (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ()))) ()))))
    (mkNodeId (0))
 )

;; (AND (A (OR B C))) (OR B C)
!(assertEqual
    (getNodeId
      (mkTree (mkNode AND)
          (cons (mkTree (mkNode A) ())
          (cons (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ()))) ())))
      (mkTree (mkNode OR)
                  (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ()))))
    (mkNodeId (2))
 )

;; Test case for isNullVertex
!(println! ("testing: isNullVertex"))
!(assertEqual (isNullVertex (mkNullVex ())) True)
!(assertEqual (isNullVertex (mkTree (mkNode A) ())) False)
!(assertEqual (isNullVertex (mkTree (mkNode B) (cons (mkNullVex ()) ()))) False)

;; Test case for tree complexity
!(println! ("testing: treeComplexity"))
!(assertEqual (treeComplexity (buildTree (AND (NOT A) (OR A B)))) 3)
!(assertEqual (treeComplexity (mkNullVex (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())) ()))) 0)
!(assertEqual (treeComplexity (mkTree (mkNode OR) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())) ()))) 1)

;; Test case for alphabetSize
!(bind! ttable1 (new-state (mkITable (cons (cons True (cons False (cons True ())))
                        (cons (cons True (cons True  (cons True ()))) ())) 
                        (cons A (cons B (cons O ()))))))
!(bind! ttable2 (new-state (mkITable
                    (cons (cons True (cons True (cons True ())))
                    (cons (cons True (cons False (cons False ())))
                    (cons (cons False (cons True (cons False ())))
                    (cons (cons False (cons False (cons False ()))) ()))))
                    (cons A (cons B (cons Output ()))))))

!(println! ("testing: alphabetSize"))
!(assertEqual (alphabetSize (get-state ttable1)) 5)
!(assertEqual (alphabetSize (get-state ttable2)) 5)
; ! (assertEqual (alphabetSize 
;       (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode P) ()) (cons (mkTree (mkNode Q) ()) ()))) 
;           (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode P) ()) ())) ())))) 
;       2)      

!(println! ("testing: extractArgs"))
!(assertEqual (extractArgs (mkTree (mkNode A) ())) (cons A ()))
!(assertEqual (extractArgs (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())))	(cons A ()))
!(assertEqual (extractArgs (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ()))))) (cons A (cons B (cons C ()))))	


; failing test case will be solved soon 
!(println! ("testing: treeFtsIndices"))
!(assertEqual (treeFtsIndices (mkTree (mkNode A) ()) (cons A (cons B (cons C (cons O ()))))) (0))
!(assertEqual (treeFtsIndices (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) ())) (cons A (cons B (cons C (cons O ())))))	(0))
!(assertEqual (treeFtsIndices (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) ())))) (cons A (cons B (cons C (cons O ()))))) (0 1 2))	

!(println! ("testing: removeLiteral"))
!(assertEqual (removeLiteral
    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ())  (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())))
    A) 	(mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) ())) ())))

!(assertEqual (removeLiteral
    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ())  (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())))
    B) 	(mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ()))))

!(assertEqual (removeLiteral (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) 
				(cons (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) ()))) A)
		(mkTree (mkNode AND) (cons (mkTree (mkNode OR) ()) ())))

!(println! ("testing: pruneExemplar"))
!(assertEqual (pruneExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ())  (cons (mkTree (mkNode OR)
                    (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())))
            (A))   
        (mkTree (mkNode AND) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) ())) ())))

!(assertEqual (pruneExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ())  (cons (mkTree (mkNode OR)
                    (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) ())))
  (A B))   (mkTree (mkNode AND) (cons (mkTree (mkNode OR) ()) ())))

!(assertEqual (pruneExemplar (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode B) ()) ()))) (A B)) 
           (mkTree (mkNode AND) ()))
