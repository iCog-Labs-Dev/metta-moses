!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:representation:knob-representation)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:representation:lsk)

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