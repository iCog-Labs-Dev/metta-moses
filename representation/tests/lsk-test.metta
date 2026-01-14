!(import! &self ../../utilities/list-methods)
!(import! &self ../../utilities/tree)
!(import! &self ../../utilities/nodeId)
!(import! &self ../../utilities/general-helpers)

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

!(import! &self ../lsk)
!(import! &self ../knob-representation)
!(import! &self ../logical-probe) 
!(import! &self ../build-logical)
!(import! &self ../build-knobs)
!(import! &self ../sample-logical-perms) 
!(import! &self ../add-logical-knobs)

; Testcases for logicalSubtreeKnob
; Testcase 1: When the subtree isn't found in the target's children list

!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))
    (mkNodeId (2))
    (mkTree (mkNode D) Nil))
  (
    (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) (Cons (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) (Cons (mkTree (mkNode C) Nil) (Cons (mkNullVex (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)))
    ( mkLSK
    (mkDiscKnob
      (mkKnob
        (mkNodeId (2 3)))
      (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil))
    ))



; Testcase 2: When the subtree is found in the target's children list
!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode OR)
      (Cons (mkTree (mkNode X) Nil)
        (Cons (mkTree (mkNode Y) Nil)
          (Cons (mkTree (mkNode Z) Nil) Nil))))
    (mkNodeId (0))
    (mkTree (mkNode Y) Nil))

  ((mkTree (mkNode OR) (Cons (mkTree (mkNode X) Nil) 
                        (Cons (mkTree (mkNode Y) Nil) 
                        (Cons (mkTree (mkNode Z) Nil) Nil)))) 
    (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2))) (mkMultip 3) (mkDiscSpec 1) (mkDiscSpec 1) Nil)))
  )



;; Testcase 3: When the negation of the subtree is found in the target's children list
!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkNullVex
                (Cons (mkTree (mkNode NOT)
                        (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil)))
    (mkNodeId (2))
    (mkTree (mkNode B) Nil))
    ((mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) 
      (Cons (mkNullVex (Cons (mkTree (mkNode NOT) (Cons (mkTree (mkNode B) Nil) Nil)) 
      (Cons (mkNullVex (Cons (mkTree (mkNode B) Nil) Nil)) Nil))) Nil))) 
      (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 2))) (mkMultip 3) (mkDiscSpec 0) (mkDiscSpec 0) Nil)))
       )

;; getNodeId test cases
!(assertEqual (getNodeId (mkLSK (mkDiscKnob (mkKnob (mkNodeId (1 0))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) )) (mkNodeId (1 0)))
!(assertEqual (getNodeId (mkLSK (mkDiscKnob (mkKnob (mkNodeId (3 5))) (mkMultip 1) (mkDiscSpec 1) (mkDiscSpec 1) Nil))) (mkNodeId (3 5)))

;; getDiscSpec
!(assertEqual (getDiscSpec (mkLSK (mkDiscKnob (mkKnob (mkNodeId (2 3))) (mkMultip 1) (mkDiscSpec 1) (mkDiscSpec 2) Nil) )) (1 2))
!(assertEqual (getDiscSpec (mkLSK (mkDiscKnob (mkKnob (mkNodeId (4 1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 1) Nil))) (0 1))

(= (tree1) (mkTree (mkNode AND)
    (Cons (mkTree (mkNode A) Nil)
      (Cons (mkTree (mkNode B) Nil) Nil))))

(= (tree2) (mkTree (mkNode OR)
            (Cons (mkTree (mkNode A) Nil)
            (Cons (mkNullVex
                    (Cons (mkTree (mkNode OR)
                             (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil))))
(= (tree3) (mkTree (mkNode OR)
            (Cons (mkTree (mkNode A) Nil)
            (Cons (mkTree (mkNode AND)
                    (Cons (mkNullVex
                            (Cons (mkTree (mkNode OR)
                                    (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil)) Nil))))
;; appendTo
;; ;; invalid disc specification
!(assertEqual
  (appendTo
    (tree1)
    (mkLSK
      (mkDiscKnob
        (mkKnob (mkNodeId (2)))
        (mkMultip 1)
        (mkDiscSpec 4)
        (mkDiscSpec 0)
        Nil)
      )
    (mkTree (mkNode OR) Nil)
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
         Nil)
      )
    (mkNullVex  Nil)
    (mkNodeId (0))
    1)
    (mkTree (mkNode AND) 
        (Cons (mkTree (mkNode A) Nil) 
        (Cons (mkTree (mkNode B) Nil) Nil))))

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
        Nil)
      )

    (mkTree (mkNode OR)
        (Cons (mkTree (mkNode A) Nil) Nil))
    (mkNodeId (0))
    2)
    (mkTree (mkNode OR)
        (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode NOT)
                 (Cons (mkTree (mkNode OR)
                 (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil)))
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
        Nil)
        )
    (mkTree (mkNode OR)
            (Cons (mkTree (mkNode A) Nil)
            (Cons (mkTree (mkNode AND) Nil) Nil)))
    (mkNodeId (2))
    2)
    (mkTree (mkNode OR)
                (Cons (mkTree (mkNode A) Nil)
                (Cons (mkTree (mkNode AND)
                        (Cons (mkTree (mkNode NOT)
                                 (Cons (mkTree (mkNode OR)
                                 (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil)) Nil)))
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
        Nil)
      )
    (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil))
    (mkNodeId (0))
    0)

    (mkTree (mkNode OR)
             (Cons (mkTree (mkNode A) Nil)
             (Cons (mkNullVex
                     (Cons (mkTree (mkNode OR)
                              (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil))))