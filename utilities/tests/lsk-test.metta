!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:general-helpers)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:knob-representation)
! (import! &self metta-moses:utilities:nodeId)
! (import! &self metta-moses:utilities:lsk)

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

;;Testcases for replaceNOdeById
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

;; Testcases for logicalSubtreeKnob
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

