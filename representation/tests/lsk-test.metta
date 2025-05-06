!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:representation:knob-representation)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:representation:lsk)
! (import! &self metta-moses:utilities:python-treehelpers)

(= (APPEND_CHILD $tree $nodeId $child ) (py_appendChild $tree $nodeId $child))
;; Testcases for logicalSubtreeKnob
;; Testcase 1: When the subtree isn't found in the target's children list
!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode AND)
      (Cons (mkTree (mkNode A) Nil)
        (Cons (mkTree (mkNode OR)
                (Cons (mkTree (mkNode B) Nil)
                  (Cons (mkTree (mkNode C) Nil) Nil))) Nil)))
    (mkNodeId (2))
    (mkTree (mkNode D) Nil))
  (mkLSK
    (mkDiscKnob
      (mkKnob
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
            (Cons (mkTree (mkNode OR)
                    (Cons (mkTree (mkNode B) Nil)
                      (Cons (mkTree (mkNode C) Nil)
                        (Cons (mkNullVex
                                (Cons (mkTree (mkNode D) Nil) Nil)) Nil)))) Nil)))
        (mkNodeId (2 3)))
      (mkMultip 3))
    (mkTree (mkNode D) Nil)))

;; Testcase 2: When the subtree is found in the target's children list
!(assertEqual
  (logicalSubtreeKnob
    (mkTree (mkNode OR)
      (Cons (mkTree (mkNode X) Nil)
        (Cons (mkTree (mkNode Y) Nil)
          (Cons (mkTree (mkNode Z) Nil) Nil))))
    (mkNodeId (0))
    (mkTree (mkNode Y) Nil))
  (mkLSK
    (mkDiscKnob
      (mkKnob
        (mkTree (mkNode OR)
          (Cons (mkTree (mkNode X) Nil)
            (Cons (mkTree (mkNode Y) Nil)
              (Cons (mkTree (mkNode Z) Nil)
                Nil))))
        (mkNodeId (0 2)))
      (mkMultip 3)
      (mkDiscSpec 1)
      (mkDiscSpec 1)
      Nil)
    (mkTree (mkNode Y) Nil)))

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
  (mkLSK
    (mkDiscKnob
      (mkKnob
        (mkTree (mkNode AND)
          (Cons (mkTree (mkNode A) Nil)
            (Cons (mkNullVex
                    (Cons (mkTree (mkNode NOT)
                            (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil)))
        (mkNodeId (2 1)))
      (mkMultip 3)
      (mkDiscSpec 1)
      (mkDiscSpec 1)
      Nil)
    (mkTree (mkNode B) Nil)))

;; getNodeId test cases
!(assertEqual (getNodeId (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode AND) (Cons (mkTree (mkNode A) Nil) Nil)) (mkNodeId (1 0))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 0) Nil) (mkTree (mkNode A) Nil))) (mkNodeId (1 0)))
!(assertEqual (getNodeId (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) Nil)) (mkNodeId (3 5))) (mkMultip 1) (mkDiscSpec 1) (mkDiscSpec 1) Nil) (mkTree (mkNode B) Nil))) (mkNodeId (3 5)))

;; getDiscSpec
! (assertEqual (getDiscSpec (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (2 3))) (mkMultip 1) (mkDiscSpec 1) (mkDiscSpec 2) Nil) (mkTree (mkNode A) Nil))) (1 2))
! (assertEqual (getDiscSpec (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (4 1))) (mkMultip 2) (mkDiscSpec 0) (mkDiscSpec 1) Nil) (mkTree (mkNode B) Nil))) (0 1))

;; getSubtree

! (assertEqual (getSubtree 
                    (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode A) Nil) (mkNodeId (1 1))) (mkMultip 1) (mkDiscSpec 0) (mkDiscSpec 0) Nil) 
                            (mkTree (mkNode B) Nil))) (mkTree (mkNode B) Nil))

! (assertEqual (getSubtree 
                    (mkLSK (mkDiscKnob (mkKnob (mkTree (mkNode B) Nil) (mkNodeId (2 2))) (mkMultip 1) (mkDiscSpec 1) (mkDiscSpec 1) Nil) 
                        (mkTree (mkNode OR) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil))))) 
                            (mkTree (mkNode OR) (Cons (mkTree (mkNode D) Nil) (Cons (mkTree (mkNode E) Nil) Nil))))

;; appendTo
;; invalid disc specification
! (assertEqual
  (appendTo
    (mkLSK
      (mkDiscKnob
        (mkKnob (mkTree (mkNode OR) Nil) (mkNodeId (0)))
        (mkMultip 1)
        (mkDiscSpec 4)
        (mkDiscSpec 0)
        Nil)
      (mkTree (mkNode A) Nil))
    (mkTree (mkNode OR) Nil)
    (mkNodeId (0))
      4
    )
  (Error 4 "Invalid disc specification:- cannot exceed 2."))

;; appending to empty tree
! (assertEqual
  (appendTo
    (mkLSK
      (mkDiscKnob
         (mkKnob
            (mkNullVex Nil)
            (mkNodeId (0)))
         (mkMultip 1)
         (mkDiscSpec 1)
         (mkDiscSpec 0)
         Nil)
    (mkTree (mkNode AND)
        (Cons (mkTree (mkNode P) Nil) Nil)))
    (mkNullVex  Nil)
    (mkNodeId (0))
    1)
    (mkTree (mkNode AND)
        (Cons (mkTree (mkNode P) Nil) Nil)))

;; Test case for insertion at a node
;; KnobSetting 2: (OR A) => (OR A (NOT (OR B)))
! (assertEqual
  (appendTo
    (mkLSK
      (mkDiscKnob
        (mkKnob
          (mkTree (mkNode OR)
            (Cons (mkTree (mkNode A) Nil)
            (Cons (mkNullVex
                    (Cons (mkTree (mkNode OR)
                             (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil)))
          (mkNodeId (2)))
        (mkMultip 3)
        (mkDiscSpec 2)
        (mkDiscSpec 0)
        Nil)
      (mkTree (mkNode OR)
         (Cons (mkTree (mkNode B) Nil) Nil)))

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
! (assertEqual
  (appendTo
    (mkLSK
      (mkDiscKnob
        (mkKnob
          (mkTree (mkNode OR)
            (Cons (mkTree (mkNode A) Nil)
            (Cons (mkTree (mkNode AND)
                    (Cons (mkNullVex
                            (Cons (mkTree (mkNode OR)
                                    (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil)) Nil)))
            (mkNodeId (2 1)))
        (mkMultip 3)
        (mkDiscSpec 2)
        (mkDiscSpec 1)
        Nil)
      (mkTree (mkNode OR)
         (Cons (mkTree (mkNode B) Nil) Nil)))
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


;; KnobSetting 0: (OR A) => (OR A)
! (assertEqual
  (appendTo
    (mkLSK
      (mkDiscKnob
        (mkKnob
          (mkTree (mkNode OR)
             (Cons (mkTree (mkNode A) Nil)
             (Cons (mkNullVex
                     (Cons (mkTree (mkNode OR)
                              (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil)))
          (mkNodeId (2)))
        (mkMultip 3)
        (mkDiscSpec 2)
        (mkDiscSpec 0)
        Nil)
      (mkTree (mkNode OR) (Cons (mkTree (mkNode B) Nil) Nil)))
    (mkTree (mkNode OR) (Cons (mkTree (mkNode A) Nil) Nil))
    (mkNodeId (0))
    0)

    (mkTree (mkNode OR)
             (Cons (mkTree (mkNode A) Nil)
             (Cons (mkNullVex
                     (Cons (mkTree (mkNode OR)
                              (Cons (mkTree (mkNode B) Nil) Nil)) Nil)) Nil))))
