!(import! &self ../../utilities/general-helpers)
!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/nodeId)

!(import! &self ../../reduct/boolean-reduct/rte-helpers)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-or)
!(import! &self ../../reduct/boolean-reduct/cut-unnecessary-and)
!(import! &self ../../reduct/boolean-reduct/n-ary-propagate-not)
!(import! &self ../../reduct/boolean-reduct/n-ary-gather-junctors)
!(import! &self ../../reduct/boolean-reduct/delete-inconsistent-handle)
!(import! &self ../../reduct/boolean-reduct/zero-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/one-constraint-subsumption)
!(import! &self ../../reduct/boolean-reduct/promote-common-constraints)
!(import! &self ../../reduct/boolean-reduct/reduce-to-elegance)

!(import! &self ../../utilities/tree)

!(import! &self ../lsk)
!(import! &self ../knob-representation)
!(import! &self ../logical-probe) 
!(import! &self ../build-logical)
!(import! &self ../build-knobs)
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)

;; Testcases for logicalSubtreeKnob
;; Testcase 1: When the subtree isn't found in the target's children list

!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkTree (mkNode OR)
                (cons (mkTree (mkNode B) ())
                  (cons (mkTree (mkNode C) ()) ()))) ())))
    (mkNodeId (2))
    (mkTree (mkNode D) ()))
  (
    (mkTree (mkNode AND) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode OR) (cons (mkTree (mkNode B) ()) (cons (mkTree (mkNode C) ()) (cons (mkNullVex (cons (mkTree (mkNode D) ()) ())) ())))) ())))
    ( mkLSK
    (mkDiscKnob
      (mkKnob
        (mkNodeId (2 3)))
      (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) ()))
    ))



; Testcase 2: When the subtree is found in the target's children list
!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode OR)
      (cons (mkTree (mkNode X) ())
        (cons (mkTree (mkNode Y) ())
          (cons (mkTree (mkNode Z) ()) ()))))
    (mkNodeId (0))
    (mkTree (mkNode Y) ()))

  ((mkTree (mkNode OR) (cons (mkTree (mkNode X) ()) 
                        (cons (mkTree (mkNode Y) ()) 
                        (cons (mkTree (mkNode Z) ()) ())))) 
    (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
  )



;; Testcase 3: When the negation of the subtree is found in the target's children list
!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
        (cons (mkNullVex
                (cons (mkTree (mkNode NOT)
                        (cons (mkTree (mkNode B) ()) ())) ())) ())))
    (mkNodeId (2))
    (mkTree (mkNode B) ()))
    ((mkTree (mkNode AND)
      (cons (mkTree (mkNode A) ())
      (cons (mkNullVex (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode B) ()) ())) ())) ()))) 
      (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 1))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) ())))
       )

;; getNodeId test cases
!(assertEqual (getNodeId (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 0))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()) )) (mkNodeId (1 0)))
!(assertEqual (getNodeId (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 5))) (mkMultip 1) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (mkNodeId (3 5)))

;; getDiscSpec
!(assertEqual (getDiscSpec (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 3))) (mkMultip 1) (mkDiscSpec 1) (mkDiscSpec 2) ()) )) (1 2))
!(assertEqual (getDiscSpec (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4 1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 1) ()))) (0 1))

(= (tree1) (mkTree (mkNode AND)
    (cons (mkTree (mkNode A) ())
      (cons (mkTree (mkNode B) ()) ()))))

(= (tree2) (mkTree (mkNode OR)
            (cons (mkTree (mkNode A) ())
            (cons (mkNullVex
                    (cons (mkTree (mkNode OR)
                             (cons (mkTree (mkNode B) ()) ())) ())) ()))))
(= (tree3) (mkTree (mkNode OR)
            (cons (mkTree (mkNode A) ())
            (cons (mkTree (mkNode AND)
                    (cons (mkNullVex
                            (cons (mkTree (mkNode OR)
                                    (cons (mkTree (mkNode B) ()) ())) ())) ())) ()))))
;; appendTo
;; invalid disc specification
!(assertEqual
  (appendTo
    (tree1)
    (mkLSK
      (mkDiscKnob
        (mkKnob (mkNodeId (2)))
        (mkMultip 1)
        (mkDiscSpec 4)
        (mkDiscSpec 0)
        ())
      )
    (mkTree (mkNode OR) ())
    (mkNodeId (0))
      4
    )
  (Error 4 "Invalid disc specification:- cannot exceed 2."))

;; appending to empty tree
!(assertEqual
  (appendTo
    (tree1)
    (mkLSK
      (mkDiscKnob
         (mkKnob
            (mkNodeId (0)))
         (mkMultip 1)
         (mkDiscSpec 1)
         (mkDiscSpec 0)
         ())
      )
    (mkNullVex  ())
    (mkNodeId (0))
    1)
    ((mkTree (mkNode AND) ()) (mkNodeId (0)) (mkNodeId (1))))

; ;; Test case for insertion at a node
; ;; KnobSetting 2: (OR A) => (OR A (NOT (OR B)))
!(assertEqual
  (appendTo
    (tree2)
    (mkLSK
      (mkDiscKnob
        (mkKnob
          (mkNodeId (2)))
        (mkMultip 3)
        (mkDiscSpec 2)
        (mkDiscSpec 0)
        ())
      )

    (mkTree (mkNode OR)
        (cons (mkTree (mkNode A) ()) ()))
    (mkNodeId (0))
    2)
    ((mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode OR) ()) ())) ()))) (mkNodeId (2 1)) (mkNodeId (2 1)))
    )

;; KnobSetting 2: (OR A (AND)) => (OR A (AND (NOT (OR B))))
!(assertEqual
  (appendTo
    (tree3)
    (mkLSK
      (mkDiscKnob
        (mkKnob
            (mkNodeId (2 1)))
        (mkMultip 3)
        (mkDiscSpec 2)
        (mkDiscSpec 1)
        ())
        )
    (mkTree (mkNode OR)
            (cons (mkTree (mkNode A) ())
            (cons (mkTree (mkNode AND) ()) ())))
    (mkNodeId (2))
    2)
    ((mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) (cons (mkTree (mkNode AND) (cons (mkTree (mkNode NOT) (cons (mkTree (mkNode OR) ()) ())) ())) ()))) (mkNodeId (2 1 1)) (mkNodeId (2 1 1)))
)


; KnobSetting 0: (OR A) => (OR A)
!(assertEqual
  (appendTo
    (tree2)
    (mkLSK
      (mkDiscKnob
        (mkKnob
          (mkNodeId (2)))
        (mkMultip 3)
        (mkDiscSpec 2)
        (mkDiscSpec 0)
        ())
      )
    (mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ()))
    (mkNodeId (0))
    0)
    ((mkTree (mkNode OR) (cons (mkTree (mkNode A) ()) ())) (mkNodeId (0)) (mkNodeId (0))))

;; Testcase 1: When the game move subtree isn't found in the target's children list
!(assertEqual
  (strategySubtreeKnob
    (mkTree (mkNode PRIORITIZED-OR)
      (cons (mkTree (mkNode playcenter) ())
        (cons (mkTree (mkNode playcorner) ()) ())))
    (mkNodeId (0))
    (mkTree (mkNode playblock) ()))
  (
    (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playcorner) ()) (cons (mkNullVex (cons (mkTree (mkNode playblock) ()) ())) ()))))
    (mkSSK (mkDiscKnob (mkKnob (mkNodeId (3))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))
  ))

;; Testcase 2: When the game move subtree is found in the target's children list
!(assertEqual
  (strategySubtreeKnob
    (mkTree (mkNode PRIORITIZED-OR)
      (cons (mkTree (mkNode playcenter) ())
        (cons (mkTree (mkNode playcorner) ())
          (cons (mkTree (mkNode playblock) ()) ()))))
    (mkNodeId (0))
    (mkTree (mkNode playcorner) ()))
  (
    (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) 
                        (cons (mkTree (mkNode playcorner) ()) 
                        (cons (mkTree (mkNode playblock) ()) ()))))
    (mkSSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))
  ))

;; getNodeId test cases for SSK
!(assertEqual (getNodeId (mkSSK (mkDiscKnob (mkKnob (mkNodeId (1 0))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) ()))) (mkNodeId (1 0)))
!(assertEqual (getNodeId (mkSSK (mkDiscKnob (mkKnob (mkNodeId (3 5))) (mkMultip 2) (mkDiscSpec 1) (mkDiscSpec 1) ()))) (mkNodeId (3 5)))

;; Game strategy trees for testing
(= (gameTree1) (mkTree (mkNode PRIORITIZED-OR)
    (cons (mkTree (mkNode playcenter) ())
      (cons (mkTree (mkNode playcorner) ()) ()))))

(= (gameTree2) (mkTree (mkNode PRIORITIZED-OR)
            (cons (mkTree (mkNode playcenter) ())
            (cons (mkNullVex
                    (cons (mkTree (mkNode playblock) ()) ())) ()))))

;; Test invalid disc specification for SSK (should not exceed 1)
!(assertEqual
  (appendToSSK
    (gameTree1)
    (mkSSK
      (mkDiscKnob
        (mkKnob (mkNodeId (2)))
        (mkMultip 2)
        (mkDiscSpec 1)
        (mkDiscSpec 0)
        ()))
    (mkTree (mkNode PRIORITIZED-OR) ())
    (mkNodeId (0))
    2)
  (Error 2 "Invalid disc specification for strategy:- cannot exceed 1."))

;; Test appending to empty tree (SSK)
!(assertEqual
  (appendToSSK
    (gameTree1)
    (mkSSK
      (mkDiscKnob
         (mkKnob (mkNodeId (0)))
         (mkMultip 2)
         (mkDiscSpec 1)
         (mkDiscSpec 0)
         ()))
    (mkNullVex ())
    (mkNodeId (0))
    1)
    ((mkTree (mkNode PRIORITIZED-OR) ()) (mkNodeId (0)) (mkNodeId (1))))

;; Test SSK KnobSetting 1: Present move
!(assertEqual
  (appendToSSK
    (gameTree2)
    (mkSSK
      (mkDiscKnob
        (mkKnob (mkNodeId (2)))
        (mkMultip 2)
        (mkDiscSpec 1)
        (mkDiscSpec 0)
        ()))
    (mkTree (mkNode PRIORITIZED-OR)
        (cons (mkTree (mkNode playcenter) ()) ()))
    (mkNodeId (0))
    1)
    ((mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) (cons (mkTree (mkNode playblock) ()) ()))) (mkNodeId (2 1)) (mkNodeId (2))))

;; Test SSK KnobSetting 0: Absent move (NullVex)
!(assertEqual
  (appendToSSK
    (gameTree2)
    (mkSSK
      (mkDiscKnob
        (mkKnob (mkNodeId (2)))
        (mkMultip 2)
        (mkDiscSpec 0)
        (mkDiscSpec 0)
        ()))
    (mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) ()))
    (mkNodeId (0))
    0)
    ((mkTree (mkNode PRIORITIZED-OR) (cons (mkTree (mkNode playcenter) ()) ())) (mkNodeId (0)) (mkNodeId (0))))
