!(register-module! ../../../metta-moses)

! (import! &self metta-moses:utilities:list-methods)
! (import! &self metta-moses:utilities:tree)
! (import! &self metta-moses:utilities:nodeId)

;;; Testcase findLevelById
!(assertEqual 
  (findLevelById 
    (mkTree (mkNode AND) 
      (Cons (mkTree (mkNode A) Nil) 
        (Cons (mkTree (mkNode OR) 
                (Cons (mkTree (mkNode B) Nil) 
                  (Cons (mkTree (mkNode C) Nil) 
                    Nil))) 
          (Cons (mkNullVex 
                  (Cons (mkTree (mkNode S) Nil) Nil)) Nil)))) 3) 
  (mkNullVex (Cons (mkTree (mkNode S) Nil) Nil)))

!(assertEqual 
  (findLevelById 
    (mkTree (mkNode OR) 
      (Cons (mkTree (mkNode A) Nil) 
      (Cons (mkNullVex 
            (Cons (mkTree (mkNode S) Nil) Nil)) Nil))) 2) 
  (mkNullVex (Cons (mkTree (mkNode S) Nil) Nil)))

;;; Testcase findNodeById 
!(assertEqual 
  (findNodeById 
    (mkTree (mkNode AND) 
      (Cons (mkTree (mkNode A) Nil) 
      (Cons (mkTree (mkNode OR) 
              (Cons (mkTree (mkNode B) Nil) 
              (Cons (mkTree (mkNode C) Nil) 
              (Cons (mkNullVex (Cons (mkTree (mkNode S) Nil) Nil)) Nil)))) 
      (Cons (mkTree (mkNode D) Nil) Nil)))) 
    (mkNodeId (2 3))) 
  (mkNullVex (Cons (mkTree (mkNode S) Nil) Nil)))

!(assertEqual 
  (findNodeById 
    (mkTree (mkNode AND) 
      (Cons (mkTree (mkNode A) Nil) 
      (Cons (mkTree (mkNode OR) 
              (Cons (mkTree (mkNode B) Nil) 
              (Cons (mkTree (mkNode C) Nil) 
              (Cons (mkNullVex (Cons (mkTree (mkNode S) Nil) Nil)) Nil)))) 
      (Cons (mkTree (mkNode D) Nil) Nil)))) 
    (mkNodeId (2 3 1))) 
  (mkTree (mkNode S) Nil))

