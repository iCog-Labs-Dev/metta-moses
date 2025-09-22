!(register-module! ../../../../metta-moses)

!(import! &self metta-moses:optimization:eda/local-structure)

;; ================================================================================
;; Local Structure Learning Tests
;; ================================================================================

;; Test univariate structure learning (should be no-op)
!(assertEqual (univariate-structure-learning () ()) ())

;; Test with minimal well-formed inputs (Representation + empty instances)
!(assertEqual 
  (univariate-structure-learning 
    (mkDeme 
      (mkRep (mkKbMap (mkDscKbMp NilMap) (mkDscMp NilMMap)) (mkTree (mkNode AND) Nil)) 
      (mkSInstSet Nil) 
      0) 
    (mkSInstSet Nil)) 
  ())




