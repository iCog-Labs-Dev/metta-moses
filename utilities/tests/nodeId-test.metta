!(import! &self ../general-helpers)

!(import! &self ../list-methods)
!(import! &self ../nodeId)
!(import! &self ../tree)

;;; Testcase getLevelById
!(assertEqual 
  (getLevelById 
    (mkTree (mkNode AND) 
      (cons (mkTree (mkNode A) ()) 
        (cons (mkTree (mkNode OR) 
                (cons (mkTree (mkNode B) ()) 
                  (cons (mkTree (mkNode C) ()) 
                    ()))) 
          (cons (mkNullVex 
                  (cons (mkTree (mkNode S) ()) ())) ())))) 3) 
  (mkNullVex (cons (mkTree (mkNode S) ()) ())))

!(assertEqual 
  (getLevelById 
    (mkTree (mkNode OR) 
      (cons (mkTree (mkNode A) ()) 
      (cons (mkNullVex 
            (cons (mkTree (mkNode S) ()) ())) ()))) 2) 
  (mkNullVex (cons (mkTree (mkNode S) ()) ())))

;;; Testcase getNodeById 
!(assertEqual 
  (getNodeById 
    (mkTree (mkNode AND) 
      (cons (mkTree (mkNode A) ()) 
      (cons (mkTree (mkNode OR) 
              (cons (mkTree (mkNode B) ()) 
              (cons (mkTree (mkNode C) ()) 
              (cons (mkNullVex (cons (mkTree (mkNode S) ()) ())) ())))) 
      (cons (mkTree (mkNode D) ()) ())))) 
    (mkNodeId (2 3))) 
  (mkNullVex (cons (mkTree (mkNode S) ()) ())))

!(assertEqual 
  (getNodeById 
    (mkTree (mkNode AND) 
      (cons (mkTree (mkNode A) ()) 
      (cons (mkTree (mkNode OR) 
              (cons (mkTree (mkNode B) ()) 
              (cons (mkTree (mkNode C) ()) 
              (cons (mkNullVex (cons (mkTree (mkNode S) ()) ())) ())))) 
      (cons (mkTree (mkNode D) ()) ())))) 
    (mkNodeId (2 3 1))) 
  (mkTree (mkNode S) ()))
